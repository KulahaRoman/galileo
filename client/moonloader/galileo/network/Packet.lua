local Packet = {}
Packet.__index = Packet

-- payload is serialized data
function Packet.new(payload)
    local object = setmetatable({}, Packet)
    object.payload = payload

    return object
end

return Packet