return function(req, res)
    res:addheader("Content-Type", "application/json; charset=utf-8")
    local outGeneral = "uptime_sec: " .. tmr.time() .. ", free_memmory_byte: " .. node.heap()
    local climate = require("climate")
    local error, temp, humidity = climate.get()
    if error == nill then
        res:send("{temp: " .. temp .. ", humidity: " .. humidity .. ", " .. outGeneral .. "}")
    else
        res:send("{error: \"" .. error .. "\", " .. outGeneral .. "}")
    end
end