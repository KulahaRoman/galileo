local Player = require("galileo.Player")
local PlayerIDProvider = require("galileo.provider.PlayerIDProvider")
local NicknameProvider = require("galileo.provider.NicknameProvider")
local PlayerStateProvider = require("galileo.provider.PlayerStateProvider")

local PlayerProvider = {}
PlayerProvider.__index = PlayerProvider

function PlayerProvider.getCurrentPlayer()
    local id = PlayerIDProvider.getCurrentPlayerID()
    local nickname = NicknameProvider.getCurrentNickname()
    local state = PlayerStateProvider.getCurrentPlayerState()

    return Player.new(id, nickname, state)
end

return PlayerProvider