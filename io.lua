mcp23017 = require("mcp23017")

buttonStateDown = 0
aRelayStatus = {}
for i = 1, config.io.relays_amount do aRelayStatus[i] = 0 end

mcp23017.begin(0x0, config.i2c.pin_sda, config.i2c.pin_scl, i2c.SLOW)

-- relays
mcp23017.writeIODIRA(0x00) -- make all GPIO pins as outputs
mcp23017.writeGPIOA(0x00)  -- make all GIPO pins off/low
mcp23017.writeIPOLA(0xFF)

-- buttons
mcp23017.writeIODIRB(0xFF) -- make all GPIO pins as inputs
mcp23017.writeGPPUB(0xFF)  -- pull up resistor
mcp23017.writeGPINTENB(0xFF)
mcp23017.writeDEFVALB(0x00)
mcp23017.writeINTCONB(0xFF)
mcp23017.writeIPOLB(0xFF)

mcp23017.readGPIOB()

function ioButtonsInterrupt()
    print("Interrupt")
    local gpiobStatusInterrupt = mcp23017.readINTCAPB()
    if buttonStateDown == 0 and gpiobStatusInterrupt > 0 then
        buttonStateDown = 1
        tmr.delay(config.io.button_delay_short_click_us)
        print("Short delay complete")
        local gpiobStatusShort = mcp23017.readGPIOB()
        if gpiobStatusShort > 0 then
            local clickType = 1
            local gpioStatusFinish = gpiobStatusShort
            tmr.delay(config.io.button_delay_long_click_us)
            print("Long delay complete")
            local gpiobStatusLong = mcp23017.readGPIOB()
            local buttonBit = 0
            if gpiobStatusLong > 0 then
                gpioStatusFinish = gpiobStatusLong
                clickType = 2
            end
            local aRelayIndexSet = {}
            for buttonBit = 0, config.io.buttons_amount - 1 do
                if bit.isset(gpioStatusFinish, buttonBit) then
                    local buttonIndex = buttonBit + 1;
                    print("Button index: " .. buttonIndex .. " type: " .. clickType)
                    mqttMessage(config.mqtt.topic_button .. "/" .. buttonIndex, clickType)
                    for key, relayIndex in pairs(config.io.buttons_actions[buttonIndex][clickType]) do
                        if not inTable(aRelayIndexSet, relayIndex) then
                            table.insert(aRelayIndexSet, relayIndex)
                        end
                    end
                end
            end
            for key, relayIndex in pairs(aRelayIndexSet) do
                ioRelaySet(relayIndex)
            end
        end
    end
    ioButtonUp()
end

function ioButtonUp(doContinue)
    if doContinue == nil then
        tmr.alarm(config.io.button_up_tmr_alarmd_id, config.io.button_up_check_ms, tmr.ALARM_AUTO, function()
            ioButtonUp(true)
        end)
    end
    if mcp23017.readGPIOB() == 0 then
        buttonStateDown = 0
        tmr.unregister(config.io.button_up_tmr_alarmd_id)
    end
end

function ioRelaySet(relayIndex, state)
    local state = state or 2;
    assert(relayIndex >= 0 and relayIndex <= config.io.relays_amount, "relayIndex := 0.." .. config.io.relays_amount)
    assert(state >= 0 and state <= 2, "state := 0..2")

    local newState = 0
    if relayIndex == 0 then
        newState = state
        local i = 1
        for i = 1, config.io.relays_amount do
            if newState == 2 then
                aRelayStatus[i] = aRelayStatus[i] == 1 and 0 or 1
            else
                aRelayStatus[i] = newState
            end
            mqttMessage(config.mqtt.topic_relay .. "/" .. i, aRelayStatus[i] == 1 and 'ON' or 'OFF')
        end
    else
        if state == 2 then
            newState = aRelayStatus[relayIndex] == 1 and 0 or 1
        else
            newState = state
        end
        aRelayStatus[relayIndex] = newState
        mqttMessage(config.mqtt.topic_relay .. "/" .. relayIndex, newState == 1 and 'ON' or 'OFF')
    end

    local gpioaStatus = 0
    local i = 1
    for i = 1, config.io.relays_amount do
        if aRelayStatus[i] > 0 then
            gpioaStatus = bit.set(gpioaStatus, i - 1)
        else
            gpioaStatus = bit.clear(gpioaStatus, i - 1)
        end
    end
    mcp23017.writeGPIOA(gpioaStatus)
end

function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return true end
    end
    return false
end

gpio.mode(config.io.pin_interrupt, gpio.INT, gpio.PULLUP)
gpio.trig(config.io.pin_interrupt, "down", ioButtonsInterrupt)
