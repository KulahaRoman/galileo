local Socket = require("socket")
local Clock = require("galileo.util.Clock")
local Connection = require("galileo.network.Connection")
local Configuration = require("galileo.config.Configuration")

local Connector = {}
Connector.__index = Connector

local TIMEOUT = Configuration.config.timing.connectorTimeout

-- returns either a valid <Connection> object or <nil, error> tuple
function Connector.connect(hostname, port)
    local socket = Socket.tcp()
    socket:settimeout(0)

    local success, err = socket:connect(hostname, port)
    if success or err == "already connected" then
        return Connection.new(socket)
    elseif err ~= "timeout" then
        return nil, err
    end

    local startTime = Clock.getCurrentTimeMillis()
    while true do
        local unused, writable = Socket.select(nil, { socket }, 0)
        if #writable > 0 then
            break
        end

        local currentTime = Clock.getCurrentTimeMillis()
        if currentTime - startTime > TIMEOUT then
            return nil, "timeout"
        end

        wait(0)
    end

    return Connection.new(socket)
end

return Connector