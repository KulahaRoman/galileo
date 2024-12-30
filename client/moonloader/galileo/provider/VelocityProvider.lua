local Vector3D = require("galileo.util.Vector3D")

local VelocityProvider = {}
VelocityProvider.__index = VelocityProvider

function VelocityProvider.getCurrentVelocity()
    if isCharSittingInAnyCar(PLAYER_PED) then
        local vehicle = storeCarCharIsInNoSave(PLAYER_PED)
        return Vector3D.new(getCarSpeedVector(vehicle))
    else
        return Vector3D.new(getCharVelocity(PLAYER_PED))
    end
end

return VelocityProvider