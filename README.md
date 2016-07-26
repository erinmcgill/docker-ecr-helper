**This Docker image should be used for Marathon**
   =============================================
**The image compliles the ECR helper Go binary from https://github.com/awslabs/amazon-ecr-credential-helper**
When the Docker container is run, it compliles the binary, places the binary as well as the compressed tarball containing the
helper configuration file, on the host itself so that they can be used for subsequent ECR pulls for all account ECR docker images.

The container only needs to run one time on the slave host.

After it has run, the Marathon application configurations **HAVE** to have the tar file in the URI.
In the example below, that file URI will be: file:///etc/docker.tar.gz

If you want to place your compressed docker tarball elsewhere on the host, replace '/etc' with the desired location

How to run the Docker container on a host manually (without Marathon):
---------------------------------------------------------------------

docker run -e $PATH=$PATH --rm -v /etc/:/data -v /opt/mesosphere/bin:/go/src/github.com/awslabs/amazon-ecr-credential-helper/bin/local/ erinmcgill/ecr-helper

Some explanation of the above command:

"-v /etc/:/data" :
Inside the container, there is a docker.tar.gz artifact that contains the necessary configuration file format to be able to use the ECR helper. This compressed tarball consists of only .docker/config.json as directed in the Mesosphere DCOS directions.

/data : the directory where the credentials are placed within the container

/etc: the directory on the how where the Marathon application configuration expects to find the compressed configuration artifact. In all other application configurations that pull from ECR, you need to set the URI to look in this directory. In the below example, it is indicated by "file:///etc/docker.tar.gz"

"-v /opt/mesosphere/bin:/go/src/github.com/awslabs/amazon-ecr-credential-helper/bin/local/" :
The container pulls are zipped copy of the github repository then runs a make to create the ecr login helper.

/go/src/github.com/awslabs/amazon-ecr-credential-helper/bin/local/: the location inside the container where the credential binary is created

/opt/mesosphere/bin : The location on the host itself where the binary will be placed to be used when pulling images from ECR

How to run the Docker container using Marathon:
----------------------------------------------

Within Marathon, create the app with the following configuration:
:::json
{
"id": "/erinmcgill/ecr-helper",
"cmd": null,
"cpus": 1,
"mem": 256,
"disk": 0,
"instances": 1,
"container": {
"type": "DOCKER",
"volumes": [
{
"containerPath": "/data",
"hostPath": "/etc",
"mode": "RW"
},
{
"containerPath": "/go/src/github.com/awslabs/amazon-ecr-credential-helper/bin/local/",
"hostPath": "/opt/mesosphere/bin/",
"mode": "RW"
}
],
"docker": {
"image": "erinmcgill/ecr-helper",
"network": "HOST",
"privileged": false,
"parameters": [],
"forcePullImage": false
}
},
"env": {
"$PATH": "$PATH"
},
"portDefinitions": [
{
"port": 10000,
"protocol": "tcp",
"labels": {}
}
]
}

Using the Cloudformation template:
---------------------------------
The cloudformation template included in this repository is slightly adjusted from the default provided when [launching the DC/OS template](https://dcos.io/docs/1.7/administration/installing/cloud/aws/)
Changes:
- AMIs that use CoreOS alpha versions to take advantage of the Docker 1.11 added feature to support for credential helpers
- Smaller instance types
- Added read-only permissions to ECR for the IAM EC2 instance roles

**Create an image from the docker file**
docker build -t ecr-helper .

Run it - mount the hosts directory inside
docker run -e $PATH=$PATH --rm -v ~/.docker:/data -v /opt/mesosphere/bin:/go/src/github.com/awslabs/amazon-ecr-credential-helper/bin/local/ ecr-helper

