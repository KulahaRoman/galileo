local PedState = {}
PedState.__index = PedState

function PedState.new(state, isInInterior, vehicleType)
    local object = setmetatable({}, PedState)
    object.state = state
    object.isInInterior = isInInterior
    object.vehicleType = vehicleType

    return object
end

function PedState.parse(table)
    local state = table.state
    local isInInterior = table.isInInterior
    local vehicleType = table.vehicleType

    return PedState.new(state, isInInterior, vehicleType)
end

function PedState:__tostring()
    return  "state="..tostring(self.state)..
            ", isInInterior="..tostring(self.isInInterior)..
            ", vehicleType="..tostring(self.vehicleType)
end

return PedState