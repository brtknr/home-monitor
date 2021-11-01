Create `config.py` and populate with admin username and password:

    cp config.py{.sample,}

Init letsencrypt (https://pentacent.medium.com/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71):

    ./scripts/init-letsencrypt.sh

Now you are ready to start your containers:

    docker-compose up -d

Now the output of `docker ps` will look something like this:

    CONTAINER ID   IMAGE                             COMMAND                  CREATED          STATUS          PORTS                                                                      NAMES
    0a7660d45fa3   home-monitor_poll-internet        "python3 poll-intern…"   17 seconds ago   Up 5 seconds                                                                               internet
    f16cb20276e3   certbot/certbot:arm64v8-v1.19.0   "/bin/sh -c 'trap ex…"   17 seconds ago   Up 5 seconds    80/tcp, 443/tcp                                                            certbot
    95a1071b72e5   grafana/grafana:8.1.5             "/run.sh"                17 seconds ago   Up 2 seconds    3000/tcp                                                                   grafana
    67b9254a6c11   home-monitor_octopus              "python3 poll-octopu…"   18 seconds ago   Up 13 seconds                                                                              octopus
    8efe839b8c56   home-monitor_patch-cloudflare     "python3 patch-cloud…"   18 seconds ago   Up 3 seconds                                                                               cloudflare
    6108d4f87f1a   home-monitor_flask-server         "flask run --host=0.…"   18 seconds ago   Up 4 seconds    0.0.0.0:5000->5000/tcp, :::5000->5000/tcp                                  flask
    19ea85a5aaa5   home-monitor_bme280               "python3 /app/poll-b…"   18 seconds ago   Up 9 seconds                                                                               bme280
    fbff9be8c0e5   nginx:1.21-alpine                 "/docker-entrypoint.…"   21 seconds ago   Up 3 seconds    0.0.0.0:80->80/tcp, :::80->80/tcp, 0.0.0.0:443->443/tcp, :::443->443/tcp   nginx
    110e7cb3da07   arm64v8/influxdb:1.7              "/entrypoint.sh infl…"   21 seconds ago   Up 18 seconds   0.0.0.0:8086->8086/tcp, :::8086->8086/tcp                                  influxdb

Exec into `influxdb` container:

    docker-compose exec influxdb bash

Create `influxdb` user:

    influx -execute "CREATE USER reader WITH PASSWORD '<password>' WITH READ PRIVILEGES"
    influx -execute "CREATE USER admin WITH PASSWORD '<password>' WITH ALL PRIVILEGES"

Change password:

    influx -username admin -password '<password>' -database 14PHCMULTI -execute "SET PASSWORD FOR reader = '<password>'"

NOTE: to install the hourly heatmap plugin, execute this inside the grafana container:

    grafana-cli plugins install marcusolsson-hourly-heatmap-panel

Configure size of log file in `/etc/docker/daemon.json`:

    {
      "log-driver": "json-file",
      "log-opts": {
        "max-size": "10m",
        "max-file": "3"
      }
    }
