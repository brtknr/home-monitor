#!/bin/bash
source /opt/poll-bme280/bin/activate
export FLASK_APP=/opt/poll-bme280/flask-server.py; flask run --host=0.0.0.0
