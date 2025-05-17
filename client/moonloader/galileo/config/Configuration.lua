local inicfg = require("inicfg")

local Configuration = {}
Configuration.__index = Configuration

Configuration.config = {}

local configFile = "galileo.ini"

function Configuration.reload()
    Configuration.config = inicfg.load({
        server = {
            hostname = "127.0.0.1",
            port = 5000
        },
        timing = {
            sampPeriod = 200,
            inputPeriod = 10,
            renderPeriod = 0,
            connectorTimeout = 5000,
            connectionTimeout = 5000
        },
        hotkeys = {
            networking = 76, -- 'L'
            markerRendering = 80, -- 'P'
            badgeRendering = 77 -- 'M'
        }
    }, configFile)
end

function Configuration.save()
    inicfg.save(Configuration.config, configFile)
end

return Configuration