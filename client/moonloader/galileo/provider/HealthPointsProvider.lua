local HealthPointsProvider = {}
HealthPointsProvider.__index = HealthPointsProvider

function HealthPointsProvider.getCurrentHealthPoints()
    return getCharHealth(PLAYER_PED)
end

return HealthPointsProvider