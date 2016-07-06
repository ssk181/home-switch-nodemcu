return function(req, res)
    res:addheader("Content-Type", "application/json; charset=utf-8")
    local outGeneral = "uptime_sec: " .. tmr.time() .. ", free_memmory_byte: " .. node.heap()
    local relayIndex = tonumber(req.params["index"]) or nil
    local relaySet   = tonumber(req.params["set"]) or nil
    local error400   = true
    if relayIndex >= 1 and relayIndex <= config.io.relays_amount then
        if relaySet == nil or (relaySet >= 0 and relaySet <= 2) then
            error400 = false
            if relaySet ~= nil then
                pcall(ioRelaySet, relayIndex, relaySet)
            end        
            res:send("{index: " .. relayIndex .. ", state: " .. aRelayStatus[relayIndex] .. ", " ..  outGeneral .. "}")
        end
    elseif relayIndex == 0 and relaySet ~= nil then
        error400 = false
        pcall(ioRelaySet, relayIndex, relaySet)
        res:send("{index: " .. relayIndex .. ", state: " .. relaySet .. ", " ..  outGeneral .. "}")
    end
    if error400 == true then
        res.statuscode = 400
        res:send("{error: \"Bad parameters. Use ?index={1-" .. config.io.relays_amount .. "}&set={0-2}\", " .. outGeneral .. "}")
    end
end