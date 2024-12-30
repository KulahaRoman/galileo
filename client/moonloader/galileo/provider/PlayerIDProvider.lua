local PlayerIDProvider = {}
PlayerIDProvider.__index = PlayerIDProvider

function PlayerIDProvider.getCurrentPlayerID()
    local unused, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    return id
end

return PlayerIDProvider