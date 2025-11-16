local VehicleIDProvider = {}
VehicleIDProvider.__index = VehicleIDProvider

VehicleIDProvider.NONE = -1

function VehicleIDProvider.getCurrentVehicleID()
    if isCharSittingInAnyCar(PLAYER_PED) then
        local vehicle = storeCarCharIsInNoSave(PLAYER_PED)
        local result, id = sampGetVehicleIdByCarHandle(vehicle)
        if result then
            return id
        end
    end
    return VehicleIDProvider.NONE
end

return VehicleIDProvider