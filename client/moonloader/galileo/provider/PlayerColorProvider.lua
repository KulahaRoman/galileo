local PlayerColorProvider = {}
PlayerColorProvider.__index = PlayerColorProvider

function PlayerColorProvider.getCurrentPlayerColor()
    local unused, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    return sampGetPlayerColor(id)
end

return PlayerColorProvider