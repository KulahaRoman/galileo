local Socket = require("socket")
local Connection = require("galileo.network.Connection")

local Connector = {}
Connector.__index = Connector

function Connector.connect(hostname, port)
    local socket = Socket.tcp()

    if not socket:connect(hostname, port) then
        return nil
    end

    return Connection.new(socket)
end

return Connector