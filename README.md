Steps:

	git clone github.com/brtknr/poll-bme280
	sudo mv poll-bme-280 /opt/poll-bme280
	sudo python3 -m venv /opt/poll-bme280
	sudo /opt/poll-bme280/setup.sh
	sudo systemctl status poll-bme280.service
