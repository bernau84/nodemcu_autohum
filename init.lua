--init.lua
gpio.mode(6, gpio.OUTPUT)
gpio.write(6, gpio.LOW)
gpio.mode(7, gpio.OUTPUT)
gpio.write(7, gpio.LOW)
    
print("Setting up WIFI...")
wifi.setmode(wifi.STATION)
--modify according your wireless router settings
wifi.sta.config("TP-LINK_BERNAU","hepterida")
wifi.sta.connect()
tmr.alarm(1, 1000, 1, function() 
if wifi.sta.getip()== nil then 
print("IP unavaiable, Waiting...") 
else 
tmr.stop(1)
print("Config done, IP is "..wifi.sta.getip())
dofile("thingspeek_dht22.lua")
end 
end)
