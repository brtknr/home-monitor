Create `config.py` and populate with admin username and password:

    cp config.py{.sample,}

Init letsencrypt (https://pentacent.medium.com/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71):

    ./scripts/init-letsencrypt.sh

Now you are ready to start your containers:

    docker-compose up -d

Exec into `influxdb` container:

    docker-compose exec influxdb bash

Create `influxdb` user:

    influx -execute "CREATE USER reader WITH PASSWORD '<password>' WITH READ PRIVILEGES"
    influx -execute "CREATE USER admin WITH PASSWORD '<password>' WITH ALL PRIVILEGES"

Change password:

    influx -username admin -password '<password>' -database 14PHCMULTI -execute "SET PASSWORD FOR reader = '<password>'"

NOTE: to install the hourly heatmap plugin, execute this inside the grafana container:

    grafana-cli plugins install marcusolsson-hourly-heatmap-panel
