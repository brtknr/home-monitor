import requests
import influxdb
import json
import time
import datetime
import sys
import aiohttp
import asyncio

from secret import credentials # template credentals provided in secret.py.sample
client = influxdb.InfluxDBClient(**credentials)
client.create_database(credentials.get('database'))
measurement = 'bme280'
endpoint  = 'http://192.168.8.%i/bme280'
rooms = [100, 110, 120]

async def fetch(session, url):
    try:
        async with session.get(url, timeout=5) as response:
            return await response.text()
    except Exception as e:
        print(e)
        return False

async def main():
    cur_time = datetime.datetime.utcnow().isoformat().split('.')[0]
    tasks = []
    async with aiohttp.ClientSession() as session:
        for room in rooms:
            url = endpoint % room
            tasks.append(fetch(session, url))
        responses = await asyncio.gather(*tasks)
        points = []
        for room, response in zip(rooms, responses):
            if response:
                fields = json.loads(response)
                point = dict(measurement=measurement, time=cur_time, fields=fields, tags=dict(room=room))
                print(point)
                points.append(point)
    try:
        client.write_points(points)
        print('Wrote %i point(s)' % len(points))
    except Exception as e:
        print(e)
    sys.stdout.flush()
    time.sleep(10)

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    while True:
        loop.run_until_complete(main())
