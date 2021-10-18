#!/usr/bin/env bash

# This script shows how to build the Docker image and push it to ECR to be ready for use
# by SageMaker.

# The argument to this script is the image name. This will be used as the image on the local
# machine and combined with the account and region to form the repository name for ECR.
image=$1
nginx_port=$2

if [ "$image" == "" ]
then
    echo "Usage: $0 <image-name>"
    exit 1
fi

if [ "$nginx_port" == "" ]
then
    nginx_port="8080"
fi

# docker run --name ${image} -d -p 8080:8080 --env SAGEMAKER_BIND_TO_PORT=${nginx_port} ${image} serve
docker run --name ${image} -d -p ${nginx_port}:${nginx_port} --env SAGEMAKER_BIND_TO_PORT=${nginx_port} ${image} serve
