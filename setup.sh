#!/bin/bash
cd /opt/poll-bme280
source ./bin/activate
pip install -r requirements.txt
sudo ln -s /opt/poll-bme280/poll-bme280.service /etc/systemd/system/poll-bme280.service
sudo ln -s /opt/poll-bme280/flask-server.service /etc/systemd/system/flask-server.service
sudo systemctl enable poll-bme280.service flask-server.service
sudo systemctl start poll-bme280.service flask-server.service
(crontab -l; echo "0 * * * * /opt/poll-bme280/poll-octopus.sh") | crontab
