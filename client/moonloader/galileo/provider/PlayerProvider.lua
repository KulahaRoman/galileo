local Player = require("galileo.Player")
local PlayerIDProvider = require("galileo.provider.PlayerIDProvider")
local NicknameProvider = require("galileo.provider.NicknameProvider")
local CoordinatesProvider = require("galileo.provider.CoordinatesProvider")
local VelocityProvider = require("galileo.provider.VelocityProvider")
local AccelerationProvider = require("galileo.provider.AccelerationProvider")
local HealthPointsProvider = require("galileo.provider.HealthPointsProvider")
local ArmourPointsProvider = require("galileo.provider.ArmourPointsProvider")
local PlayerColorProvider = require("galileo.provider.PlayerColorProvider")
local VehicleProvider = require("galileo.provider.VehicleProvider")
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
    local vehicle = VehicleProvider.getCurrentVehicle()
    local interior = InteriorProvider.getCurrentInterior()
    local connected = ConnectionStatusProvider.getCurrentStatus()
    local afk = false

    return Player.new(id, nickname, coords, velocity, acceleration,
                    color, hp, ap, vehicle, interior, connected, afk)
end

return PlayerProvider