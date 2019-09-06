dofile("bme280.lua")
dofile("credentials.lua") -- template credentials provided as credentials.lua.sample

outpin = 4
retries = 0
timer_connect = tmr.create()
timer_inactive = tmr.create()

function init()
  connect ()
  gpio.mode(outpin, gpio.OUTPUT)
  timer_inactive:alarm(20000, tmr.ALARM_AUTO, function()
    if retries < 3 then
      if retries > 0 then
        print("No activity for " .. retries .. " retries, will attempt to reconnect to Wifi")
        connect ()
      end
      retries = retries + 1
    else
      print("Restarting after " .. retries .. " retries in case the device is being funny")
      node.restart() --maxed out retries, restart
    end
  end)
end

function togLED()
  gpio.write(outpin, gpio.LOW)
  tmr.delay(500)
  gpio.write(outpin, gpio.HIGH)
end

function connect()
  print("Connecting to WiFi using provided credentials (" .. creds.ssid .. ", " .. creds.pwd .. ")")
  wifi.setmode(wifi.STATION)
  -- creds struct must have ssid and pwd properties
  wifi.sta.config(creds)
  -- wifi.sta.connect() not necessary because config() uses auto-connect=true by default
  timer_connect:alarm(1000, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() == nil then
      togLED()
    else
      print("WiFi connection established, IP address: " .. wifi.sta.getip())
      timer_connect:unregister()
      gpio.write(outpin, gpio.LOW)
    end
  end)
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
      togLED()
    end
  end)
end)

init()
