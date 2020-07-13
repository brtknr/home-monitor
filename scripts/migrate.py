from influxdb import InfluxDBClient

from config import credentials

client = InfluxDBClient(**credentials)
measurement = "internet"
measurement2 = "internet2"
server = "1.1.1.1"

for i in range(10):
    db_data = client.query(
        "select * from %s where time>=now()-%id and time<=now()-%id"
        % (measurement, i + 1, i),
        database="14PHCMULTI",
    )

    def process(row):
        time = row.pop("time")
        server = row.pop("server")
        delay = row.pop("delay")
        result = list()
        if delay:
            result.append(
                {
                    "measurement": measurement2,
                    "tags": dict(server=server),
                    "time": time,
                    "fields": dict(delay=delay),
                }
            )
        else:
            print(row)
        return result

    data_to_write = list()
    for d in db_data.get_points():
        data_to_write.extend(process(d))
    print(i, len(data_to_write))
    if data_to_write:
        print(data_to_write[0])
        # client.write_points(data_to_write)
