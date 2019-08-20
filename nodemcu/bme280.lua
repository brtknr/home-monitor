sda, scl = 6, 7
alt=15 -- altitude of Bedminister, Bristol in meters

i2c.setup(0, sda, scl, i2c.SLOW) -- call i2c.setup() only once
bme280.setup()

function readBME280()
  T, P, H, QNH = bme280.read(alt)
  -- T temperature in celsius as an integer multiplied with 100
  -- P air pressure in hectopascals multiplied by 1000
  -- H relative humidity in percent multiplied by 1000
  -- QNH air pressure in hectopascals multiplied by 1000 converted to sea level
  D = bme280.dewpoint(H, T)
  -- For given temperature and relative humidity returns the dew point in celsius as an integer multiplied with 100.
  return string.format('{"T": %0.2f, "P": %0.3f, "QNH": %0.3f, "H": %0.3f, "D": %0.3f}', T/100, P/1000, QNH/1000, H/1000, D/100)
end

print(readBME280()) -- test print the output on startup

-- altimeter function - calculate altitude based on current sea level pressure (QNH) and measure pressure
-- P = bme280.baro()
-- curAlt = bme280.altitude(P, QNH)
-- local curAltsgn = (curAlt < 0 and -1 or 1); curAlt = curAltsgn*curAlt
-- print(string.format("altitude=%s%d.%02d", curAltsgn<0 and "-" or "", curAlt/100, curAlt%100))
