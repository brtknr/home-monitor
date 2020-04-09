from flask import Flask, Response
import influxdb
import json
from config import credentials, measurement
client = influxdb.InfluxDBClient(**credentials)

app = Flask(__name__)

@app.route('/interval/<interval>', methods=['GET'])
def get_readings(interval):
    query = ('SELECT mean(*) FROM %s'
             ' WHERE time > now() - %s'
             ' GROUP BY room' % (measurement, interval))
    print(query)
    results = {}
    for (m, d), v in client.query(query).items():
        results[d.get('room')] = list(v)
    dump = json.dumps(results, indent=4)
    resp = Response(dump, status=200, mimetype="application/json")
    print(dump, resp)
    return resp
