Install InfluxDB:

    sudo apt install influxdb
    sudo systemctl enable influxdb
    sudo systemctl start influxdb

Create `influxdb` user:

    influx -execute "CREATE USER reader WITH PASSWORD '<password>' WITH READ PRIVILEGES"
    influx -execute "CREATE USER admin WITH PASSWORD '<password>' WITH ALL PRIVILEGES"

Change password:

    influx -username admin -password '<password>' -database 14PHCMULTI -execute "SET PASSWORD FOR reader = '<password>'"

Now you will want want to set `auth-enabled = true` inside `/etc/influxdb/influxdb.conf` before exposing your database to the web.

    sudo systemctl restart influxdb

Init grafana user:
    sudo systemctl stop grafana-server
    sudo userdel grafana
    sudo useradd --uid 472 grafana --shell /bin/false --home-dir /usr/share/grafana
    sudo chown -R root:grafana /etc/grafana
    sudo chown -R grafana:grafana /var/{lib,log}/grafana
    sudo usermod -aG grafana $USER

Create `config.py` and populate with admin username and password:

    cp config.py{.sample,}

Init letsencrypt (https://pentacent.medium.com/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71):

    ./init-letsencrypt.sh

Now you are ready to start your containers:

    docker-compose up -d --build
