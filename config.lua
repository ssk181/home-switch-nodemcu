config = {
    network = {
        ssid         = "MyWiFiRouter",
        password     = "Password",
        tmr_alarm_id = 0,
        tmr_retry_ms = 20000
    },
    collectgarbage = {
        tmr_alarm_id = 1,
        tmr_run_ms   = 60000
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
        queue_ttl_sec  = 3600,
        queue_max_size = 50,
        topic_online   = "online",
        topic_button   = "button",
        topic_relay    = "relay",
        topic_climate_temp     = "climate/temp",
        topic_climate_humidity = "climate/humidity",
        topic_state_uptime = "state/uptime",
        topic_state_memory = "state/memory",
        topic          = "/home/iot",
        dir_in         = "in",
        dir_out        = "out",
        msg_on         = "ON",
        msg_off        = "OFF",
        msg_invert     = "INVERT",
        climate_cache_sec = 15
    }
}
