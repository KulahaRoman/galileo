local Player = require("galileo.Player")
local NicknameProvider = require("galileo.provider.NicknameProvider")
local PlayerStateProvider = require("galileo.provider.PlayerStateProvider")

local PlayerProvider = {}
PlayerProvider.__index = PlayerProvider

function PlayerProvider.getCurrentPlayer()
    local nickname = NicknameProvider.getCurrentNickname()
    local state = PlayerStateProvider.getCurrentPlayerState()

    return Player.new(nickname, state)
end

return PlayerProvider