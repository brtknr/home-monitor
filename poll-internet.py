import influxdb
from config import credentials, ping_servers, interval
from ping3 import ping
import datetime
import asyncio
import time
import sys

client = influxdb.InfluxDBClient(**credentials)
client.create_database(credentials.get("database"))

measurement = "internet"

# points = list()
# cur_time = datetime.datetime.utcnow().isoformat().split('.')[0]
# for server in ping_servers:
#    delay = ping(server)
#    points.append(point)
# if points:
#    client.write_points(points)
#    print(points)
# print('Wrote {n} points.'.format(n=len(points)))


async def async_ping(server):
    delay = await ping(server)
    return delay


async def main():
    start = time.time()
    cur_time = datetime.datetime.utcnow().isoformat().split(".")[0]
    tasks = []
    loop = asyncio.get_event_loop()
    for server in ping_servers:
        tasks.append(loop.run_in_executor(None, ping, server))
    delays = await asyncio.gather(*tasks)
    points = []
    for server, delay in zip(ping_servers, delays):
        if delay != None:
            point = dict(
                measurement=measurement,
                time=cur_time,
                fields=dict(delay=delay),
                tags=dict(server=server),
            )
            print(server, point)
            points.append(point)
        else:
            print(server, delay)
    if points:
        try:
            client.write_points(points)
        except Exception as e:
            print(e)
    elapsed = time.time() - start
    print("Wrote %i point(s), elapsed %0.1f seconds" % (len(points), elapsed))
    sys.stdout.flush()


if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    while True:
        modulus = time.time() % interval
        difference = interval - modulus
        if modulus > 0.1 and difference > 0.1:
            time.sleep(difference)
        loop.run_until_complete(main())
