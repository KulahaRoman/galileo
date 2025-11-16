local VehicleModelProvider = {}
VehicleModelProvider.__index = VehicleModelProvider

VehicleModelProvider.NONE = -1

function VehicleModelProvider.getCurrentVehicleModel()
    if isCharSittingInAnyCar(PLAYER_PED) then
        local vehicle = storeCarCharIsInNoSave(PLAYER_PED)
        return getCarModel(vehicle)
    end
    return VehicleModelProvider.NONE
end

return VehicleModelProvider