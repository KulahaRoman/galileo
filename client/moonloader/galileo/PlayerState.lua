local Vector3D = require("galileo.util.Vector3D")
local PedState = require("galileo.PedState")

local PlayerState = {}
PlayerState.__index = PlayerState

function PlayerState.new(pedState, pedCoords, pedColor, pedHP, pedAP)
    local object = setmetatable({}, PlayerState)
    object.pedState = pedState
    object.pedCoords = pedCoords
    object.pedColor = pedColor
    object.pedHP = pedHP
    object.pedAP = pedAP

    return object
end

function PlayerState.parse(table)
    local pedState = PedState.parse(table.pedState)
    local pedCoords = Vector3D.parse(table.pedCoords)
    local pedColor = table.pedColor
    local pedHP = table.pedHP
    local pedAP = table.pedAP

    return PlayerState.new(pedState, pedCoords, pedColor, pedHP, pedAP)
end

function PlayerState:__tostring()
    return  "pedState="..tostring(self.pedState)..
            ", pedCoords="..tostring(self.pedCoords)..
            ", pedColor="..tostring(self.pedColor)..
            ", pedHP="..tostring(self.pedHP)..
            ", pedAP="..tostring(self.pedAP)
end

return PlayerState