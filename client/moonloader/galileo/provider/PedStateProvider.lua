local PedState = require("galileo.PedState")

local PedStateProvider = {}
PedStateProvider.__index = PedStateProvider

function PedStateProvider.getCurrentPedState()
    local state = "foot"
    local isInInterior = false
    local vehicleType = "nil"

    return PedState.new(state, isInInterior, vehicleType)
end

return PedStateProvider