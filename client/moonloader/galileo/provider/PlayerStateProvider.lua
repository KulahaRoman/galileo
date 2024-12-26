local PlayerState = require("galileo.PlayerState")

local PedStateProvider = require("galileo.provider.PedStateProvider")
local CoordinatesProvider = require("galileo.provider.CoordinatesProvider")
local HealthPointsProvider = require("galileo.provider.HealthPointsProvider")
local ArmourPointsProvider = require("galileo.provider.ArmourPointsProvider")
local PlayerColorProvider = require("galileo.provider.PlayerColorProvider")

local PlayerStateProvider = {}
PlayerStateProvider.__index = PlayerStateProvider

function PlayerStateProvider.getCurrentPlayerState()
    local state = PedStateProvider.getCurrentPedState()
    local coords = CoordinatesProvider.getCurrentCoordinates()
    local color = PlayerColorProvider.getCurrentPlayerColor()
    local hp = HealthPointsProvider.getCurrentHealthPoints()
    local ap = ArmourPointsProvider.getCurrentArmourPoints()

    return PlayerState.new(state, coords, color, hp, ap)
end

return PlayerStateProvider