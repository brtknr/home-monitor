import influxdb
import requests
import json
import time
import datetime
from secret import credentials

measurement = 'bme280'
endpoint  = 'http://192.168.8.110/bme280'

client = influxdb.InfluxDBClient(**credentials)
client.create_database(credentials.get('database'))

while True:
    try:
        fields = json.loads(requests.get(endpoint).content)
        cur_time = datetime.datetime.utcnow().isoformat().split('.')[0]
        point = dict(measurement=measurement, time=cur_time, fields=fields) 
        print(point)
        client.write_points([point])
    except Exception as e:
        print('Error', e)
    time.sleep(10)
