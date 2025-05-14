local ServerProvider = {}
ServerProvider.__index = ServerProvider

function ServerProvider.getCurrentServer()
    local address, port = sampGetCurrentServerAddress()
    return address .. ":" .. port
end

return ServerProvider