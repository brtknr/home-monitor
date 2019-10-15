#!/bin/bash
cd /opt/poll-bme280
source ./bin/activate
python poll-octopus.py | tee poll-octopus.log
