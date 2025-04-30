local VehicleProvider = {}
VehicleProvider.__index = VehicleProvider

VehicleProvider.NONE = -1

function VehicleProvider.getCurrentVehicle()
    if isCharSittingInAnyCar(PLAYER_PED) then
        local vehicle = storeCarCharIsInNoSave(PLAYER_PED)
        return getCarModel(vehicle)
    end
    return VehicleProvider.NONE
end

return VehicleProvider