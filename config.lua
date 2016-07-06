config = {
    network = {
        ssid         = "MyWiFiRouter",
        password     = "Password",
        tmr_alarm_id = 0,
        tmr_retry_ms = 20000
    },
    httpd = {
        port         = 80,
        tmr_alarm_id = 1,
        tmr_retry_ms = 3000
    },
    i2c = {
        pin_sda = 3,
        pin_scl = 4
	},
    io = {
        buttons_amount   = 4, -- 1 to 8
        relays_amount    = 5, -- 1 to 8
        pin_interrupt    = 6,
        button_delay_short_click_us = 20000,
        button_delay_long_click_us  = 500000,
        buttin_delay_debounce_us    = 50000,
        buttons_actions = { -- linked relays on short click and on long click
            {{1}, {4}}, -- button 1
            {{2}, {4}}, -- button 2
            {{3}, {4}}, -- button 3
            {{5}, {5}}  -- button 4
        }
    },
    dht = {
        pin = 1, -- GPIO pin index or nil if disabled
    },
    mqtt = {
        broker_ip      = "192.168.182.2",
        port           = 1883,
        user           = "",
        password       = "",
        keep_alive_sec = 60,
        tmr_alarm_id   = 2,
        tmr_retry_ms   = 3000,
        type_online    = "online",
        type_button    = "button",
        type_relay     = "relay",
        topic          = "/home/iot"
    }
}
