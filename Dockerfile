# This file was developed to be used in AWS EC2 with Marathon to ease authenticating when pulling ECR-housed Docker images

# Because the Amazon ECR Helper is a go binary, we are using the office golang docker image as the base image
FROM golang:1.6

MAINTAINER Erin "EMoney" McGill

RUN apt-get update && apt-get install -y \ 
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Marathon requires a gzipped credntial file - this compressed tarball contains ./docker/config.json
# The JSON file contains the following: { "credsStore": "ecr-login" }
# There is no secret or confidential account information needed  

COPY docker.tar.gz /tmp/

# Creating the necessary github directories and pulling a zip of the master branch from the repository using the wget command
# This avoids having to install the Git client

RUN mkdir -p /go/src/github.com/awslabs/amazon-ecr-credential-helper/

ADD https://github.com/awslabs/amazon-ecr-credential-helper/archive/master.zip /go/src/github.com/awslabs/amazon-ecr-credential-helper/master.zip

WORKDIR /go/src/github.com/awslabs/amazon-ecr-credential-helper/
RUN unzip master.zip && \
    mv amazon-ecr-credential-helper-master/* . && \
    rm -rf amazon-ecr-credential-helper-master && \
    rm -f master.zip

# Compile the binary with make - the binary will be created in the /go/src/github.com/awslabs/amazon-ecr-credential-helper/bin/local
# directory inside the container
#
# To ensure that the host has the necessary files after the container runs and is removed, the user has to mount 2 volumes from the host
#  - mapped to the container's /go/src/github.com/awslabs/amazon-ecr-credential-helper/bin/local directory
#  - mapped to the container's /data directory

CMD /usr/bin/make && cp /tmp/docker.tar.gz /data 
