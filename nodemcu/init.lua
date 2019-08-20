dofile("credentials.lua")
dofile("bme280.lua")

local outpin = 4
local state = false
local active = false
local timer = tmr.create()
local timer_inactive = tmr.create()

function init()
  gpio.mode(outpin, gpio.OUTPUT)
  connect()
end

function togLED()
  gpio.write(outpin, gpio.LOW)
  tmr.delay(500)
  gpio.write(outpin, gpio.HIGH)
end

function startup()
  if file.open("init.lua") == nil then
    print("init.lua deleted or renamed")
  else
    print("WiFi connection established, IP address: " .. wifi.sta.getip())
    file.close("init.lua")
    gpio.write(outpin, gpio.LOW)
    timer_inactive:alarm(30000, tmr.ALARM_AUTO, function()
      if active then
        active = false
      else
	print("Restarting in case wifi died")
        node.restart() --inactive twice in a row, restart
      end
    end)
  end
end

function connect()
  print("Connecting to WiFi access point...")
  print(creds.ssid)
  print(creds.pwd)
  wifi.setmode(wifi.STATION)
  wifi.sta.config(creds) -- creds struct must have ssid and pwd properties
  -- wifi.sta.connect() not necessary because config() uses auto-connect=true by default
end

timer:alarm(1000, tmr.ALARM_AUTO, function()
  if wifi.sta.getip() == nil then
    togLED()
  else
    timer:unregister()
    startup()
  end
end)

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
  conn:on("receive", function(conn,payload)
    print(payload)  -- View the received data,
    fnd = {string.find(payload, "/bme280 ")}
    if #fnd ~= 0 then
      active = true
      conn:send('HTTP/1.0 200 OK\r\n')
      conn:send('Content-Type: application/json\r\n\r\n')
      conn:send(readBME280())
      conn:on("sent", function(conn) conn:close() end)
      togLED()
    end
  end)
end)

init()
connect()
