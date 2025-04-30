local Struct = require("struct")
local Socket = require("socket")
local Clock = require("galileo.util.Clock")
local Packet = require("galileo.network.Packet")
local Configuration = require("galileo.config.Configuration")

local Connection = {}
Connection.__index = Connection

local TIMEOUT = Configuration.config.timing.connectionTimeout

function Connection.new(socket)
    local object = setmetatable({}, Connection)
    object.socket = socket

    return object
end

-- returns either a total sent bytes number or <nil, error> tuple
function Connection:write(packet)
    local payloadLength = #packet.payload
    local payloadData = packet.payload

    local data = Struct.pack(">I4", payloadLength) .. payloadData
    local dataLength = #data

    local totalSent = 0

    local startTime = Clock.getCurrentTimeMillis()
    while totalSent < dataLength do
        local unused, writable = Socket.select(nil, { self.socket }, 0)
        if #writable > 0 then
            local sent, err, last = self.socket:send(data, totalSent + 1)
            if err and err ~= "timeout" then
                return nil, err
            end
            totalSent = last or sent or totalSent
        end

        local currentTime = Clock.getCurrentTimeMillis()
        if totalSent < dataLength and currentTime - startTime > TIMEOUT then
            return nil, "timeout"
        end

        wait(0)
    end

    return totalSent
end

-- returns either a valid <Packet> object or <nil, error> tuple
function Connection:read()
    local startTime = Clock.getCurrentTimeMillis()

    local payloadLengthBytes = ""
    while #payloadLengthBytes < 4 do
        local readable = Socket.select({ self.socket }, nil, 0)
        if #readable > 0 then
            local data, err, partial = self.socket:receive(4 - #payloadLengthBytes)
            if err and err ~= "timeout" then
                return nil, err
            end
            payloadLengthBytes = payloadLengthBytes .. (data or partial or "")
        end

        local currentTime = Clock.getCurrentTimeMillis()
        if #payloadLengthBytes < 4 and currentTime - startTime > TIMEOUT then
            return nil, "timeout"
        end

        wait(0)
    end

    local payloadLength = Struct.unpack(">I4", payloadLengthBytes)

    local payloadData = ""
    while #payloadData < payloadLength do
        local readable = Socket.select({ self.socket }, nil, 0)
        if #readable > 0 then
            local data, err, partial = self.socket:receive(payloadLength - #payloadData)
            if err and err ~= "timeout" then
                return nil, err
            end
            payloadData = payloadData .. (data or partial or "")
        end

        local currentTime = Clock.getCurrentTimeMillis()
        if #payloadData < payloadLength and currentTime - startTime > TIMEOUT then
            return nil, "timeout"
        end

        wait(0)
    end

    return Packet.new(payloadData)
end

function Connection:close()
    self.socket:close()
end

return Connection