#!/bin/bash
DIR=`dirname $0`
source $DIR/bin/activate
python $DIR/poll-octopus.py | tee $DIR/poll-octopus.log
