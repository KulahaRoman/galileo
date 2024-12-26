local Vector3D = require("galileo.util.Vector3D")

local CoordinatesProvider = {}
CoordinatesProvider.__index = CoordinatesProvider

function CoordinatesProvider.getCurrentCoordinates()
    return Vector3D.new(getCharCoordinates(PLAYER_PED))
end

return CoordinatesProvider