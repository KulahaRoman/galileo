local Socket = require("socket")

local Clock = {}
Clock.__index = Clock

function Clock.getCurrentTimeMillis()
    return Socket.gettime() * 1000
end

return Clock