#!/bin/bash
cd /opt/poll-bme280
source ./bin/activate
pip install -r requirements.txt
ln -s /opt/poll-bme280/poll-bme280.service /etc/systemd/system/poll-bme280.service
systemctl enable poll-bme280.service
systemctl start poll-bme280.service
(crontab -l; echo "0 * * * * /opt/poll-bme280/poll-octopus.sh") | crontab
