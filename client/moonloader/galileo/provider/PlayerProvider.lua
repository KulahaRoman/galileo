local Player = require("galileo.Player")
local PlayerIDProvider = require("galileo.provider.PlayerIDProvider")
local NicknameProvider = require("galileo.provider.NicknameProvider")
local CoordinatesProvider = require("galileo.provider.CoordinatesProvider")
local VelocityProvider = require("galileo.provider.VelocityProvider")
local AccelerationProvider = require("galileo.provider.AccelerationProvider")
local HealthPointsProvider = require("galileo.provider.HealthPointsProvider")
local ArmourPointsProvider = require("galileo.provider.ArmourPointsProvider")
local PlayerColorProvider = require("galileo.provider.PlayerColorProvider")
local VehicleModelProvider = require("galileo.provider.VehicleModelProvider")
local VehicleIDProvider = require("galileo.provider.VehicleIDProvider")
local VehicleSeatProvider = require("galileo.provider.VehicleSeatProvider")
local InteriorProvider = require("galileo.provider.InteriorProvider")
local ConnectionStatusProvider = require("galileo.provider.ConnectionStatusProvider")

local PlayerProvider = {}
PlayerProvider.__index = PlayerProvider

function PlayerProvider.getCurrentPlayer()
    local id = PlayerIDProvider.getCurrentPlayerID()
    local nickname = NicknameProvider.getCurrentNickname()
    local coords = CoordinatesProvider.getCurrentCoordinates()
    local velocity = VelocityProvider.getCurrentVelocity()
    local acceleration = AccelerationProvider.getCurrentAcceleration(velocity)
    local color = PlayerColorProvider.getCurrentPlayerColor()
    local hp = HealthPointsProvider.getCurrentHealthPoints()
    local ap = ArmourPointsProvider.getCurrentArmourPoints()
    local vehicleModel = VehicleModelProvider.getCurrentVehicleModel()
    local vehicleID = VehicleIDProvider.getCurrentVehicleID()
    local vehicleSeat = VehicleSeatProvider.getCurrentVehicleSeat()
    local interior = InteriorProvider.getCurrentInterior()
    local connected = ConnectionStatusProvider.getCurrentStatus()
    local afk = false

    return Player.new(  id, nickname, coords, velocity, acceleration,
                        color, hp, ap, vehicleModel, vehicleID, 
                        vehicleSeat, interior, connected, afk   )
end

return PlayerProvider