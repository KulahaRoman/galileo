local Struct = require("struct")
local Packet = require("galileo.network.Packet")

local Connection = {}
Connection.__index = Connection

function Connection.new(socket)
    local object = setmetatable({}, Connection)
    object.socket = socket
    object.socket:settimeout(0)

    return object
end

function Connection:write(packet)
    local payloadLength = #packet.payload
    local payloadData = packet.payload

    local data = Struct.pack(">I4", payloadLength) .. payloadData

    self.socket:send(data)
end

function Connection:read()
    local payloadLengthBytes
    while not payloadLengthBytes do
        payloadLengthBytes = self.socket:receive(4)
        wait(0)
    end

    local payloadLength = Struct.unpack(">I4", payloadLengthBytes)

    local payloadData
    while not payloadData do
        payloadData = self.socket:receive(payloadLength)
        wait(0)
    end

    return Packet.new(payloadData)
end

return Connection