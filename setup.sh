#!/bin/bash
DIR=`dirname $0`
FULLPATH=`cd $DIR >/dev/null 2>&1 ; pwd -P`
source $DIR/bin/activate
pip install -r $DIR/requirements.txt
for service in poll-bme280 poll-internet flask-server; do
    sudo cat << EOF | sudo tee /etc/systemd/system/$service.service
[Unit]
Description=$service service

[Service]
ExecStart=$FULLPATH/$service.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl enable $service.service
    sudo systemctl daemon-reload
    sudo systemctl restart $service.service
done
(sudo crontab -l; echo "0 * * * * $FULLPATH/poll-octopus.sh") | uniq | sudo crontab
