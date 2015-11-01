function releon()
    gpio.write(6, gpio.LOW)
    gpio.write(7, gpio.HIGH)
    tmr.delay(200000)
    gpio.write(6, gpio.LOW)
    gpio.write(7, gpio.LOW)
end


function releoff()
    gpio.write(6, gpio.HIGH)
    gpio.write(7, gpio.LOW)
    tmr.delay(200000)
    gpio.write(6, gpio.LOW)
    gpio.write(7, gpio.LOW)
end

ReleOffHum = 60
ReleOnHum = 70
ReleOnTemp = 10
ReleOffTemp = 50

function sendData()

print("Acquiring data from sensor")
Sta = -2
Rep = 20
while (Sta ~= 0) and (Rep) do
    Sta,Temperature,Humidity=dht.read(1)
    print("Measurement: T=" ..Temperature..", H="..Humidity)
    tmr.delay(100000)
    Rep = Rep - 1
end

if Sta == 0 then
    if (Humidity >= ReleOnHum) or (Temperature <= ReleOnTemp) then
        print("Humidity over threshod - heating turned on!!")
        releon()
    end
    if (Humidity <= ReleOffHum) or (Temperature >= ReleOffTemp) then
        print("Humidity below threshod - heating turned off!!")
        releoff()
    end
end
        

-- conection to thingspeak.com
print("Sending data to thingspeak.com")
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)
-- api.thingspeak.com 184.106.153.149
conn:connect(80,'184.106.153.149') 
--conn:send("GET /update?api_key=JF1AHCQJQF7IJS70&talkback_key=EI4CDVJE5LAWRRMC&field1="..Temperature.."&field2="..Humidity.." HTTP/1.1\r\n") 
conn:send("GET /update?api_key=JF1AHCQJQF7IJS70&talkback_key=EI4CDVJE5LAWRRMC&field1="..Temperature.."&field2="..Humidity.."&field3="..ReleOffHum.."&field4="..ReleOnHum.." HTTP/1.1\r\n") 
conn:send("Host: api.thingspeak.com\r\n") 
conn:send("Accept: */*\r\n") 
conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
conn:send("\r\n")
--conn:on("sent",function(conn)
--                     print("Closing connection")
--                      conn:close()
--                  end)
conn:on("disconnection", function(conn)
                      print("Got disconnection...")
  end)
conn:on("receive", function(conn, payload)
                      --print("TalkBack"..payload)
                      pos = string.find(payload, "##1")
                      if pos ~= nil then
                        releon()
                        print("TalkBack: Rele ON")
                      end
                      pos = string.find(payload, "##0")
                      if pos ~= nil then
                        releoff() 
                        print("TalkBack: Rele OFF")                                             
                      end
                      pos = string.find(payload, "##HIH%d+")
                      if pos ~= nil then
                        ReleOnHum = tonumber(string.sub(payload,pos+5,pos+6))
                        print("TalkBack: Heat on humidity threshold"..ReleOnHum)                                             
                      end 
                      pos = string.find(payload, "##LOH%d+")
                      if pos ~= nil then 
                        ReleOffHum = tonumber(string.sub(payload,pos+5,pos+6))
                        print("TalkBack: Heat off humidity threshold"..ReleOffHum)                                             
                      end  
                      
  end)  
end

-- send data every X ms to thing speak
tmr.alarm(2, 30000, 1, function() sendData() end )
