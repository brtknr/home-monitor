#!/bin/bash
DIR=`dirname $0`
source $DIR/bin/activate
python $DIR/poll-bme280.py
