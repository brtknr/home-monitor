#!/bin/bash
set -x
cd /opt/poll-bme280
source ./bin/activate
pip install -r requirements.txt
for service in poll-bme280 poll-internet flask-server; do
    sudo ln -sf /opt/poll-bme280/$service.service /etc/systemd/system/$service.service
    sudo systemctl enable $service.service
    sudo systemctl start $service.service
done
#(sudo crontab -l; echo "0 * * * * /opt/poll-bme280/poll-octopus.sh") | sudo crontab
