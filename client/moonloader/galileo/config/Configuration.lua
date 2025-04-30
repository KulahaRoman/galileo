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
            sampCheckPeriod = 200,
            inputPeriod = 10,
            renderPeriod = 0,
            connectorTimeout = 5000,
            connectionTimeout = 5000
        },
        hotkeys = {
            networking = 76, -- 'L'
            rendering = 80 -- 'P'
        }
    }, configFile)
end

function Configuration.save()
    inicfg.save(Configuration.config, configFile)
end

return Configuration