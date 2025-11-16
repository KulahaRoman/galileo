local VehicleSeatProvider = {}
VehicleSeatProvider.__index = VehicleSeatProvider

VehicleSeatProvider.NONE = -1
VehicleSeatProvider.DRIVER = 100

function VehicleSeatProvider.getCurrentVehicleSeat()
    if isCharSittingInAnyCar(PLAYER_PED) then
        local vehicle = storeCarCharIsInNoSave(PLAYER_PED)
        local driver = getDriverOfCar(vehicle)
        if driver == PLAYER_PED then
            return VehicleSeatProvider.DRIVER
        end

        local maxPass = getMaximumNumberOfPassengers(vehicle)
        for i=0, maxPass, 1 do
            local ped = getCharInCarPassengerSeat(vehicle, i)
            if ped == PLAYER_PED then
                return i
            end
        end
    end
    return VehicleSeatProvider.NONE
end

return VehicleSeatProvider