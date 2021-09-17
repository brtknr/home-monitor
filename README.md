Install InfluxDB:

    sudo apt install influxdb
    sudo systemctl enable influxdb
    sudo systemctl start influxdb

Create `influxdb` user:

    influx -execute "CREATE USER <username> WITH PASSWORD '<password>' WITH ALL PRIVILEGES"

Now you will want want to set `auth-enabled = true` inside `/etc/influxdb/influxdb.conf` before exposing your database to the web.

    sudo systemctl restart influxdb

Create `config.py` and populate with admin username and password:

    cp config.py{.sample,}

Now you are ready to start your containers:

    docker-compose up -d --build
