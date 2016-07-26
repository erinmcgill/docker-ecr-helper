FROM golang:1.6

RUN apt-get -y update && apt-get install unzip

COPY docker.tar.gz /tmp/

RUN mkdir -p src/github.com/awslabs/amazon-ecr-credential-helper/ && wget -O src/github.com/awslabs/amazon-ecr-credential-helper/master.zip --no-check-certificate https://github.com/awslabs/amazon-ecr-credential-helper/archive/master.zip

WORKDIR /go/src/github.com/awslabs/amazon-ecr-credential-helper/
RUN unzip master.zip && mv amazon-ecr-credential-helper-master/* . && rm -rf amazon-ecr-credential-helper-master && rm -f master.zip

CMD /usr/bin/make && cp /tmp/docker.tar.gz /data && cp /tmp/docker-credential-helper.zip /data
