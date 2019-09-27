import requests
import influxdb
import json
import time
import datetime
import sys
import aiohttp
import asyncio

from config import credentials
from config import measurement, endpoint, rooms
from config import interval, timeout

client = influxdb.InfluxDBClient(**credentials)
client.create_database(credentials.get('database'))


async def fetch(session, url):
    try:
        async with session.get(url, timeout=timeout) as response:
            return await response.text()
    except Exception as e:
        return e


async def main():
    cur_time = datetime.datetime.utcnow().isoformat().split('.')[0]
    tasks = []
    start = time.time()
    async with aiohttp.ClientSession() as session:
        for room in rooms:
            url = endpoint % room
            tasks.append(fetch(session, url))
        responses = await asyncio.gather(*tasks)
        points = []
        for room, response in zip(rooms, responses):
            if type(response) == str:
                fields = json.loads(response)
                point = dict(measurement=measurement, time=cur_time, fields=fields, tags=dict(room=room))
                print(room, point)
                points.append(point)
            else:
                print(room, type(response), response)
    if points:
        try:
            client.write_points(points)
        except Exception as e:
            print(e)
    elapsed = time.time() - start
    print('Wrote %i point(s), elapsed %0.1f seconds' % (len(points), elapsed))
    sys.stdout.flush()
    time.sleep(max(0, interval - elapsed))


if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    while True:
        loop.run_until_complete(main())
