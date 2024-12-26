local Socket = require("socket")
local Connection = require("galileo.network.Connection")

local Connector = {}
Connector.__index = Connector

function Connector.connect(hostname, port)
    local socket = Socket.tcp()
    socket:connect(hostname, port)
    return Connection.new(socket)
end

return Connector