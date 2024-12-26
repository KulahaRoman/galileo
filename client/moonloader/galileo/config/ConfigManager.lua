local inicfg = require("inicfg")
local configFile = "galileo.ini"

local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new()
    local object = setmetatable({}, ConfigManager)
    object:reload()
    object:save()

    return object
end

function ConfigManager:reload()
    self.config = inicfg.load({
        server ={
            hostname = "127.0.0.1",
            port = 5000
        }
    }, configFile)
end

function ConfigManager:save()
    inicfg.save(self.config, configFile)
end

return ConfigManager