from influxdb import InfluxDBClient

from secret import credentials
client = InfluxDBClient(**credentials)
measurement = 'bme280'
room = 110

for i in range(30):
    db_data = client.query('select * from %s where time>now()-%id and time<now()-%id' % (measurement, i+1, i), database='14PHC')
    def process(row):
        time = row.pop('time')
        row = {k: float(v) for k,v in row.items()}
        return {'measurement': measurement,
                'tags': dict(room=room),
                'time': time,
                'fields': row,
        }
    data_to_write = [process(d) for d in db_data.get_points()]
    print(i, len(data_to_write))
    if data_to_write:
        print(data_to_write[0])
        client.write_points(data_to_write)
