local PlayerState = require("galileo.PlayerState")

local PedStateProvider = require("galileo.provider.PedStateProvider")
local CoordinatesProvider = require("galileo.provider.CoordinatesProvider")
local VelocityProvider = require("galileo.provider.VelocityProvider")
local AccelerationProvider = require("galileo.provider.AccelerationProvider")
local HealthPointsProvider = require("galileo.provider.HealthPointsProvider")
local ArmourPointsProvider = require("galileo.provider.ArmourPointsProvider")
local PlayerColorProvider = require("galileo.provider.PlayerColorProvider")

local PlayerStateProvider = {}
PlayerStateProvider.__index = PlayerStateProvider

function PlayerStateProvider.getCurrentPlayerState()
    local state = PedStateProvider.getCurrentPedState()
    local coords = CoordinatesProvider.getCurrentCoordinates()
    local velocity = VelocityProvider.getCurrentVelocity()
    local acceleration = AccelerationProvider.getCurrentAcceleration(velocity)
    local color = PlayerColorProvider.getCurrentPlayerColor()
    local hp = HealthPointsProvider.getCurrentHealthPoints()
    local ap = ArmourPointsProvider.getCurrentArmourPoints()

    return PlayerState.new(state, coords, velocity, acceleration, color, hp, ap)
end

return PlayerStateProvider