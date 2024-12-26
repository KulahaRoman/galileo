local ArmourPointsProvider = {}
ArmourPointsProvider.__index = ArmourPointsProvider

function ArmourPointsProvider.getCurrentArmourPoints()
    return getCharArmour(PLAYER_PED)
end

return ArmourPointsProvider