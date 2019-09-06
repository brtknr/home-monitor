Install InfluxDB:

	sudo apt install influxdb
	sudo systemctl enable influxdb
	sudo systemctl start influxdb
	sudo systemctl status influxdb

Create `influxdb` user and fill in `secret.py` with admin username and password:

	influx -execute "CREATE USER <username> WITH PASSWORD '<password>' WITH ALL PRIVILEGES"
	cp secret.py{.sample,}

At this point, you want want to set `auth-enabled = true` inside
`/etc/influxdb/influxdb.conf` if you want to expose your database to the web.

Now you are ready to start your polling service:

	git clone github.com/brtknr/poll-bme280
	sudo mv poll-bme-280 /opt/poll-bme280
	sudo python3 -m venv /opt/poll-bme280
	sudo /opt/poll-bme280/setup.sh
	sudo systemctl status poll-bme280.service
