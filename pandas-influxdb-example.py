import pandas
import influxdb
from config import credentials, measurement
client = influxdb.DataFrameClient(**credentials)
query = ('select * from %s'
         ' where time < now() - 90m and time > now() - 100m'
         ' limit 10' % measurement)

if __name__ == '__main__':
    df = client.query(query).get(measurement)
    print(df.describe())
