tmr.alarm(config.httpd.tmr_alarm_id, config.httpd.tmr_retry_ms, tmr.ALARM_AUTO, function() 
    print("HTTPD Waiting for a network")
    if wifi.sta.status() == wifi.STA_GOTIP then 
        print("HTTPD Got a network")
        tmr.stop(config.httpd.tmr_alarm_id)
        local espress = require "espress"
        local server = espress.createserver()
        server:use("routes_auto.lc")
        server:listen(config.httpd.port)
    end
end)