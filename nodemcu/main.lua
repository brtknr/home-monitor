outpin = 4
retries = 0
timer_connect = tmr.create()
timer_reconnect = tmr.create()

function main()
  if file.open("bme280.lc") then
    file.close()
    dofile("bme280.lc")
  else
    dofile("bme280.lua")
  end
  
  if file.open("config.lc") then
    file.close()
    dofile("config.lc")
  else
    dofile("config.lua")
  end

  srv=net.createServer(net.TCP)
  srv:listen(80, function(conn)
    conn:on("receive", function(conn,payload)
      -- print(payload)  -- view the received data
      fnd = {string.find(payload, "/bme280 ")}
      if #fnd ~= 0 then
        conn:send('HTTP/1.0 200 OK\r\n')
        conn:send('Content-Type: application/json\r\n\r\n')
        conn:send(readBME280())
        conn:on("sent", function(conn) conn:close() end)
        retries = 0
        togLED(500)
      end
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
