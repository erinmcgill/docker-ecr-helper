Create an image from the docker file
	docker build -t ecr-helper .

Run it - mount the hosts directory inside
	docker run -e $PATH=$PATH --rm -v ~/.docker:/data -v /opt/mesosphere/bin:/go/src/github.com/awslabs/amazon-ecr-credential-helper/bin/local/ ecr-helper


