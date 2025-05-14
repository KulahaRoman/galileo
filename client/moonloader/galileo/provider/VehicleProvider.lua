local VehicleProvider = {}
VehicleProvider.__index = VehicleProvider

local NONE = -1

function VehicleProvider.getCurrentVehicle()
    if isCharSittingInAnyCar(PLAYER_PED) then
        local vehicle = storeCarCharIsInNoSave(PLAYER_PED)
        return getCarModel(vehicle)
    end
    return NONE
end

return VehicleProvider