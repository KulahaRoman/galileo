local ConnectionStatusProvider = {}
ConnectionStatusProvider.__index = ConnectionStatusProvider

local connected = false

function onReceiveRpc()
    connected = true
end

function onReceivePacket(id)
    if id == 34 then
        connected = true
    end
    if id == 32 or id == 33 then
        connected = false
    end
end

function ConnectionStatusProvider.getCurrentStatus()
    return connected
end

return ConnectionStatusProvider