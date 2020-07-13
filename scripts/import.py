import influxdb
import json
from secret import credentials

measurement = "bme280"

client = influxdb.InfluxDBClient(**credentials)
client.create_database(credentials.get("database"))

with open("temp.log") as f:
    lines = f.readlines()
    points = []
    for l in lines:
        cur_time, f = l.split("\t")
        fields = json.loads(f)
        point = dict(measurement=measurement, time=cur_time, fields=fields)
        print(point)
        points.append(point)
    client.write_points(points)
