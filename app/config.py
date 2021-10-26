import secret

credentials = dict(
    host="influxdb",
    database="14PHCMULTI",
    username="admin",
    password=secret.db_password,  # sensitive
)

measurement = "nodemcu"
endpoint = "http://192.168.8.%i/bme280"
rooms = [100, 110, 120]

interval = 10  # seconds between polling
timeout = 5  # seconds before timing out
ping_servers = ["1.1.1.1", "8.8.8.8"]


class OctopusEnergy:
    mpan = "2200042794417"
    meter_no = "18P5002923"
    interval = 300  # seconds between polling
    api_key = secret.octopus_api_key
    period_from = None # "2021-10-10T00:00:00Z"


class CloudFlare:
    email = "brtknr@bath.edu"
    zone = "bab7acfb3951e5efe21ee3b7ccb83356"
    records = {"dash.rawn.uk"}
    interval = 30  # seconds between polling
    token = secret.cloudflare_token
