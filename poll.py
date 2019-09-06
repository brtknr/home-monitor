import requests
import influxdb
import json
import time
import datetime
import sys

from secret import credentials # template credentals provided in secret.py.sample

measurement = 'bme280'
endpoint  = 'http://192.168.8.%i/bme280'
rooms = [100, 110]

client = influxdb.InfluxDBClient(**credentials)
client.create_database(credentials.get('database'))

points = list()
while True:
    for room in rooms:
        try:
            fields = json.loads(requests.get(endpoint%room, timeout=1).content)
            cur_time = datetime.datetime.utcnow().isoformat().split('.')[0]
            point = dict(measurement=measurement, time=cur_time, fields=fields, tags=dict(room=room))
            print(point)
            points.append(point)
        except Exception as e:
            print(e)
    try:
        client.write_points(points)
        points.clear()
    except Exception as e:
        print(e)
    sys.stdout.flush()
    time.sleep(10)
