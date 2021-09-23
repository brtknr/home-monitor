outpin = 4
retries = 0
timer_connect = tmr.create()
timer_reconnect = tmr.create()

function main()
  dofile("bme280.lua")
  dofile("config.lua")
  srv=net.createServer(net.TCP)
  srv:listen(80, function(conn)
    conn:on("receive", function(conn,payload)
      print(payload)  -- view the received data
      fnd = {string.find(payload, "/bme280 ")}
      fnd0 = {string.find(payload, "GET /")}
      fnd1 = {string.find(payload, " HTTP/1.1")}
      link = string.sub(payload, fnd0[2]+1, fnd1[1]-1)

      result = "{}"
      if link == 'bme280' or link == 'measurements' then
	T, P, QNH, H, D = readBME280()
	-- wifi received signal strength indicator
	RSSI = wifi.sta.getrssi()
        -- For given temperature and relative humidity returns the dew point in celsius as an integer multiplied with 100.
        result = string.format('{"T": %0.2f, "P": %0.3f, "QNH": %0.3f, "H": %0.3f, "D": %0.3f, "RSSI": %i}', T, P, QNH, H, D, RSSI)
      end
      conn:send('HTTP/1.0 200 OK\r\n')
      conn:send('Content-Type: application/json\r\n\r\n')
      conn:send(result)
      conn:on("sent", function(conn) conn:close() end)
      retries = 0
      togLED(500)
    end)
  end)

  gpio.mode(outpin, gpio.OUTPUT)
  connect ()
  timer_reconnect:alarm(timeout_reconnect, tmr.ALARM_AUTO, function()
    if retries > 0 then
      print("No activity for " .. retries .. " retries, reconnect to Wifi")
      connect ()
    end
    retries = retries + 1
  end)
end

function togLED(delay)
  gpio.write(outpin, gpio.LOW)
  tmr.delay(delay)
  gpio.write(outpin, gpio.HIGH)
end

function connect()
  print("Connecting to WiFi using provided credentials (" .. creds.ssid .. ", " .. creds.pwd .. ")")
  wifi.setmode(wifi.STATION)
  -- creds struct must have ssid and pwd properties
  wifi.sta.disconnect()
  wifi.sta.config(creds)
  -- wifi.sta.connect() not necessary because config() uses auto-connect=true by default
  timer_connect:alarm(1000, tmr.ALARM_AUTO, function()
    if wifi.sta.status() == wifi.STA_GOTIP then
      print("WiFi connection established, IP address: " .. wifi.sta.getip())
      timer_connect:unregister()
      gpio.write(outpin, gpio.LOW)
    elseif wifi.sta.status() == wifi.STA_CONNECTING then
      togLED(500)
    else
      print("Error, WiFi status is: " .. wifi.sta.status())
      togLED(1000)
    end
  end)
end

main()
