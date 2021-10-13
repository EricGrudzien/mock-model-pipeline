# Bring-your-own Algorithm Sample

This example shows how to package a mock algorithm for use with SageMaker. 

Thanks to these Repos:
1. https://github.com/aws/amazon-sagemaker-examples/blob/master/advanced_functionality/scikit_bring_your_own/container/ReadMe.md
2. https://github.com/giuseppeporcelli/sagemaker-custom-serving-containers/blob/49e0f373dbfe204996cc70100eae78dfb5653be3/nginx-gunicorn-flask-container/notebook/nginx-gunicorn-flask-container.ipynb


SageMaker supports two execution modes: _training_ where the algorithm uses input data to train a new model and _serving_ where the algorithm accepts HTTP requests and uses the previously trained model to do an inference (also called "scoring", "prediction", or "transformation").


In order to build a production grade inference server into the container, we use the following stack to make the implementer's job simple:

1. __[nginx][nginx]__ is a light-weight layer that handles the incoming HTTP requests and manages the I/O in and out of the container efficiently.
2. __[gunicorn][gunicorn]__ is a WSGI pre-forking worker server that runs multiple copies of your application and load balances between them.
3. __[flask][flask]__ is a simple web framework used in the inference app that you write. It lets you respond to call on the `/ping` and `/invocations` endpoints without having to write much code.

## The Structure of the Sample Code

The components are as follows:

* __Dockerfile__: The _Dockerfile_ describes how the image is built and what it contains. It is a recipe for your container and gives you tremendous flexibility to construct almost any execution environment you can imagine. Here. we use the Dockerfile to describe a pretty standard python science stack and the simple scripts that we're going to add to it. See the [Dockerfile reference][dockerfile] for what's possible here.

* __build.sh__: The script to build the Docker image (using the Dockerfile above) locally (on your local machine).

* __build\_and\_push.sh__: The script to build the Docker image (using the Dockerfile above) and push it to the [Amazon EC2 Container Registry (ECR)][ecr] so that it can be deployed to SageMaker. Specify the name of the image as the argument to this script. The script will generate a full name for the repository in your account and your configured AWS region. If this ECR repository doesn't exist, the script will create it.

* __start.sh__: A convenience script that starts a docker image locally, and maps Docker port to SageMaker appropriate port 8080.

* __stop.sh__: A convenience script that stops a locally running container and removes the associate image

### The application run inside the container

When SageMaker starts a container, it will invoke the container with an argument of either __train__ or __serve__. We have set this container up so that the argument in treated as the command that the container executes. When training, it will run the __train__ program included and, when serving, it will run the __serve__ program.

* __train__: The main program for training the model. When you build your own algorithm, you'll edit this to include your training code.
* __serve__: The wrapper that starts the inference server. In most cases, you can use this file as-is.
* __wsgi.py__: The start up shell for the individual server workers. This only needs to be changed if you changed where predictor.py is located or is named.
* __predictor.py__: The algorithm-specific inference server. This is the file that you modify with your own algorithm's code.
* __nginx.conf__: The configuration for the nginx master server that manages the multiple workers.


## Environment variables

When you create an inference server, you can control some of Gunicorn's options via environment variables. These
can be supplied as part of the CreateModel API call.

    Parameter                Environment Variable              Default Value
    ---------                --------------------              -------------
    number of workers        MODEL_SERVER_WORKERS              the number of CPU cores
    timeout                  MODEL_SERVER_TIMEOUT              60 seconds


## Command line
Here are sample commands:

```console
foo@bar:~$ ./build.sh mmkv
```

```console
foo@bar:~$ ./start.sh mmkv
```

```console
foo@bar:~$ ./stop.sh mmkv
```


## Issues
* If cannot run sh commands above, make sure to set scripts as executable.

For example:

```console
foo@bar:~$ chmod +x ./build.sh
```



* If executing ./build_and_push.sh, make sure to have authenticated into AWS and credentials available / set in terminal used for executing these files. 


[skl]: http://scikit-learn.org "scikit-learn Home Page"
[dockerfile]: https://docs.docker.com/engine/reference/builder/ "The official Dockerfile reference guide"
[ecr]: https://aws.amazon.com/ecr/ "ECR Home Page"
[nginx]: http://nginx.org/
[gunicorn]: http://gunicorn.org/
[flask]: http://flask.pocoo.org/
# mock-model-pipeline
