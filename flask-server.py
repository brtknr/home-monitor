from flask import Flask, Response
import influxdb
import json
from config import credentials, measurement

client = influxdb.InfluxDBClient(**credentials)

app = Flask(__name__)


def get_readings(i="1m"):
    query = (
        "SELECT mean(*) FROM %s"
        " WHERE time > now() - %s"
        " GROUP BY room" % (measurement, i)
    )
    print(query)
    r = {}
    t = ""
    for (m, d), _v in client.query(query).items():
        raw = list(_v).pop()
        t = raw.pop("time")
        r[d.get("room")] = {k: round(v, 2) for k, v in raw.items()}
    resp_dict = dict(time=t, interval=i, rooms=r)
    return json.dumps(resp_dict, indent=4)


@app.route("/", methods=["GET"])
def get_default():
    dump = get_readings()
    resp = Response(dump, status=200, mimetype="application/json")
    print(dump, resp)
    return resp


@app.route("/interval/<interval>", methods=["GET"])
def get_interval(interval):
    dump = get_readings(interval)
    resp = Response(dump, status=200, mimetype="application/json")
    print(dump, resp)
    return resp
