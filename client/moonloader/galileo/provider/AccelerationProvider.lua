local Vector3D = require("galileo.util.Vector3D")

local AccelerationProvider = {}
AccelerationProvider.__index = AccelerationProvider

local previousVelocity = Vector3D.new(0, 0, 0)

function AccelerationProvider.getCurrentAcceleration(currentVelocity)
    local acceleration = Vector3D.sub(currentVelocity, previousVelocity)
    previousVelocity = currentVelocity

    return acceleration
end

return AccelerationProvider