#!/usr/bin/env bash

# This script shows how to build the Docker image and push it to ECR to be ready for use
# by SageMaker.

# The argument to this script is the image name. This will be used as the image on the local
# machine and combined with the account and region to form the repository name for ECR.
image=$1

if [ "$image" == "" ]
then
    echo "Usage: $0 <image-name>"
    exit 1
fi

cd ./${image}

chmod +x src/train
chmod +x src/serve

# Get the account number associated with the current IAM credentials
{ # try
    account=$(aws sts get-caller-identity --query Account --output text) &&
    isAuth=1
} || { # catch
    # save log for exception 
    account="1111"
    isAuth=0
}

echo "isAuth " ${isAuth}
echo "account" ${account}

if [ $? -ne 0 ]
then
    exit 255
fi

# Get the region defined in the current configuration (default to us-west-2 if none defined)
region=$(aws configure get region)
region=${region:-us-west-2}


fullname="${account}.dkr.ecr.${region}.amazonaws.com/${image}:latest"
echo "fullname " ${fullname}

docker build  -t ${image} .
docker tag ${image} ${fullname}

if [ $isAuth -eq 1 ];
then 
    echo "Pushing container"
    # If the repository doesn't exist in ECR, create it.
    aws ecr describe-repositories --repository-names "${image}" > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        aws ecr create-repository --repository-name "${image}" > /dev/null
    fi

    # Get the login command from ECR and execute it directly
    aws ecr get-login-password --region "${region}" | docker login --username AWS --password-stdin "${account}".dkr.ecr."${region}".amazonaws.com

    # Build the docker image locally with the image name and then push it to ECR
    # with the full name.
    docker push ${fullname}
else
    echo "Local container build complete"
fi


cd ..