local Struct = require("struct")
local Packet = require("galileo.network.Packet")

local Connection = {}
Connection.__index = Connection

function Connection.new(socket)
    local object = setmetatable({}, Connection)
    object.socket = socket

    return object
end

function Connection:write(packet)
    local payloadLength = #packet.payload
    local payloadData = packet.payload

    local data = Struct.pack(">I4", payloadLength) .. payloadData

    self.socket:send(data)
end

function Connection:read()
    local payloadLengthBytes = self.socket:receive(4)
    local payloadLength = Struct.unpack(">I4", payloadLengthBytes)

    local payloadData = self.socket:receive(payloadLength)

    return Packet.new(payloadData)
end

return Connection