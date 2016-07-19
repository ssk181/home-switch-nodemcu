dofile("config.lc")
dofile("io.lc")
dofile("network.lc")
dofile("mqtt.lc")

tmr.alarm(config.collectgarbage.tmr_alarm_id, config.collectgarbage.tmr_run_ms, tmr.ALARM_AUTO, function()
    collectgarbage()
end)