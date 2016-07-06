local moduleName = ... 
local M = {}
_G[moduleName] = M

function M.get()
    local errorMsg = "Climate is disabled"
    local returnTemp = nil
    local returnHumidity = nil
    if config.dht.pin ~= nil then
        errorMsg = nil
        local status, temp, humi, temp_dec, humi_dec = dht.read(config.dht.pin)
        if status == dht.OK then
             -- Integer firmware
            returnTemp     = string.format("%d.%03d", math.floor(temp), temp_dec)
            returnHumidity = string.format("%d.%03d", math.floor(humi), humi_dec)

            -- Float firmware
            -- returnTemp     = temp
            -- returnHumidity = humi
        elseif status == dht.ERROR_CHECKSUM then
            errorMsg = "DHT checksum error"
        elseif status == dht.ERROR_TIMEOUT then
            errorMsg = "DHT timed out"
        end
    end
    return errorMsg, returnTemp, returnHumidity
end

return M