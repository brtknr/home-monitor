#!/bin/bash
DIR=`dirname $0`
source $DIR/bin/activate
export FLASK_APP=$DIR/flask-server.py; flask run --host=0.0.0.0
