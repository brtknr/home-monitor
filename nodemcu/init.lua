countdown = 3
timer_main = tmr.create()
timer_main:alarm(1000, tmr.ALARM_AUTO, function()
  print(countdown)
  countdown = countdown-1
  if countdown<1 then
    timer_main:stop()
    countdown = nil
    local s,err
    if file.open("main.lc") then
      file.close()
      s,err = pcall(function() dofile("main.lc") end)
    else
      s,err = pcall(function() dofile("main.lua") end)
    end
    if not s then
      print(err)
      node.restart()
    end
  end
end)
