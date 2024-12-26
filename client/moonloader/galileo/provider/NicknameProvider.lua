local NicknameProvider = {}
NicknameProvider.__index = NicknameProvider

function NicknameProvider.getCurrentNickname()
    local unused, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    return sampGetPlayerNickname(id)
end

return NicknameProvider