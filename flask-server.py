from flask import Flask, Response
import influxdb
import json
from config import credentials, measurement
client = influxdb.InfluxDBClient(**credentials)

app = Flask(__name__)

@app.route('/interval/<i>', methods=['GET'])
def get_readings(i):
    query = ('SELECT mean(*) FROM %s'
             ' WHERE time > now() - %s'
             ' GROUP BY room' % (measurement, i))
    print(query)
    r = {}
    t = ""
    for (m, d), _v in client.query(query).items():
        raw = list(_v).pop()
        t = raw.pop('time')
        r[d.get('room')] = {k: round(v, 2) for k, v in raw.items()}
    resp_dict = dict(time=t, interval=i, rooms=r)
    dump = json.dumps(resp_dict, indent=4)
    resp = Response(dump, status=200, mimetype="application/json")
    print(dump, resp)
    return resp
