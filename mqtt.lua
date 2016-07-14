mqttConnected = false
mqttQueue = {}

function mqttMessage(type, message)
    if mqttConnected then
        local ip = wifi.sta.getip() or "none"
        mqttClient:publish(config.mqtt.topic .. "/" .. ip .. "/" .. type, message, 0, 1, function(client)
            print("MQTT message sended") 
        end)
        print("MQTT message: " .. config.mqtt.topic .. "/" .. ip .. "/" .. type .. " - " .. message)
    else
        mqttQueueAdd(type, message)
    end
end

function mqttConnect(firstReconnect)
    if firstReconnect then
        mqttConnected = false
        mqttClean()
    end
    tmr.alarm(config.mqtt.tmr_alarm_id, config.mqtt.tmr_retry_ms, tmr.ALARM_AUTO, function()
        print("MQTT Waiting for a network")
        if wifi.sta.status() == wifi.STA_GOTIP then
            print("MQTT Got a network")           
            mqttClient = mqtt.Client(wifi.sta.getip(), config.mqtt.keep_alive_sec)
            local ip = wifi.sta.getip() or "none"
            mqttClient:lwt(config.mqtt.topic, "{ip: \"" .. ip .. "\", type: \"" .. config.mqtt.type_online .. "\", action: 0}", 0, 0)
            mqttClient:on("offline", function(client) mqttConnect(true) end)
            mqttClient:on("connect", function(client)
                tmr.stop(config.mqtt.tmr_alarm_id)
                mqttMessage(config.mqtt.type_online, 1)
                mqttConnected = true
                print("MQTT connected success")
                mqttQueueSend()
            end)
            mqttClient:connect(config.mqtt.broker_ip, config.mqtt.port, false, false,
                function(client, reason)
                    print("MQTT can\'t connect. Error: " .. reason)
                end
            )
        end
    end)
end

function mqttClean()
    if mqttClient ~= nil then
        mqttClient:close()
        mqttClient = nil
        collectgarbage("collect")
        print("MQTT cleaned")
    end
end

function mqttQueueAdd(type, message)
    local timeLine = tmr.time() - config.mqtt.queue_ttl_sec
    local i = 1
    while i <= #mqttQueue do
        if mqttQueue[i]["time"] < timeLine or i > config.mqtt.queue_max_size then
            table.remove(mqttQueue, i)
        else
            i = i + 1
        end
    end
    table.insert(mqttQueue, {time = tmr.time(), type = type, message = message})
end

function mqttQueueSend()
    local msg = nil
    local i = 1    
    while i <= #mqttQueue do
        if mqttConnected then
            msg = mqttQueue[i]
            table.remove(mqttQueue, i)
            mqttMessage(msg["type"], msg["message"])
        else
            i = i + 1
        end
    end
end

mqttConnect()