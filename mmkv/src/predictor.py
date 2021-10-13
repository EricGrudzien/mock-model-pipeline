# This is the file that implements a flask server to do inferences. 

from __future__ import print_function
from typing import DefaultDict
from flask import jsonify
import json
import flask

print("In predictor.py")

# The flask app for serving predictions
app = flask.Flask(__name__)

@app.route("/ping", methods=["GET"])
def ping():
    """Determine if the container is working and healthy. In this sample container, we declare
    it healthy if we can load the model successfully."""

    print("ping: In predictor.py")
    status = 200 
    return flask.Response(response="\n", status=status, mimetype="application/json")


@app.route("/invocations", methods=["POST"])
def transformation():
    """Do an inference on a single batch of data. In this sample server, we take data as CSV, convert
    it to a pandas data frame for internal use and then convert the predictions back to CSV (which really
    just means one prediction per line, since there's a single column.
    """
    print("invocations: In predictor.py")
    data = None

    data_in = flask.request.json
    print("received json: " + json.dumps(data_in, indent=4))

    if flask.request.content_type == "application/json":
        if data_in["value"] > 10:
            data = {
            "key": data_in["key"],
            "value": 1,
            "previous": data_in["value"],
            "result": "Previous was greater, updated value to 1",
        }   
        else:
            data = {
                "key": data_in["key"],
                "value": 100,
                "previous": data_in["value"],
                "result": "Previous was less than or equal, updated value to 100",
            }
    else:
        return flask.Response(
            response="This predictor only supports json data", status=415, mimetype="text/plain"
        )

    print("response: " + json.dumps(data, indent=4))
    return jsonify(data), 200
