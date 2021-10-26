import sys
import time
import requests
import influxdb

from config import credentials
from config import OctopusEnergy


def main():
    client = influxdb.InfluxDBClient(**credentials)
    client.create_database(credentials.get("database"))

    base_url = "https://api.octopus.energy/v1/electricity-meter-points"
    endpoint = "{base_url}/{mpan}/meters/{meter_no}/consumption/".format(
        base_url=base_url, mpan=OctopusEnergy.mpan, meter_no=OctopusEnergy.meter_no
    )
    session = requests.Session()
    session.auth = (OctopusEnergy.api_key, "")
    measurement = "electricity"

    params = dict(page=1)
    result = client.query(
        "select * from {measurement} order by time desc limit 1".format(
            measurement=measurement
        )
    )
    if result:
        params["period_from"] = OctopusEnergy.period_from or list(result).pop().pop().get("time")
    print(params)

    while endpoint:
        print(endpoint)
        response = session.get(endpoint, params=params).json()
        params = {}  # HACK: reset this to an empty dict after first use
        results = response.get("results", [])
        points = list()
        for result in results:
            point = dict(
                measurement=measurement,
                time=result.get("interval_start"),
                fields=dict(consumption=result.get("consumption")),
            )
            points.append(point)
        if points:
            client.write_points(points)
        print("Wrote {n} points.".format(n=len(points)))
        endpoint = response.get("next", None)


if __name__ == "__main__":
    while True:
        modulus = time.time() % OctopusEnergy.interval
        difference = OctopusEnergy.interval - modulus
        if modulus > 0.1 and difference > 0.1:
            print("Sleeping for", difference)
            sys.stdout.flush()
            time.sleep(difference)
        main()
