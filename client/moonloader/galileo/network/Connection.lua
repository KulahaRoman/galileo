local Struct = require("struct")
local Clock = require("galileo.util.Clock")
local Packet = require("galileo.network.Packet")

local Connection = {}
Connection.__index = Connection

Connection.timeout = 5000 -- 5 seconds

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
    local invokationTime = Clock.getCurrentTimeMillis()

    local payloadLengthBytes
    while not payloadLengthBytes do
        payloadLengthBytes = self.socket:receive(4)

        local currentTime = Clock.getCurrentTimeMillis()
        if not payloadLengthBytes and currentTime - invokationTime > Connection.timeout then
            return nil
        end

        wait(0)
    end

    local payloadLength = Struct.unpack(">I4", payloadLengthBytes)

    local payloadData
    while not payloadData do
        payloadData = self.socket:receive(payloadLength)

        local currentTime = Clock.getCurrentTimeMillis()
        if not payloadData and currentTime - invokationTime > Connection.timeout then
            return nil
        end

        wait(0)
    end

    return Packet.new(payloadData)
end

function Connection:close()
    self.socket:close()
end

return Connection