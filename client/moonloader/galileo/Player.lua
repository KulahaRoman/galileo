local PlayerState = require("galileo.PlayerState")

local Player = {}
Player.__index = Player

function Player.new(id, nickname, state)
    local object = setmetatable({}, Player)
    object.id = id
    object.nickname = nickname
    object.state = state

    return object
end

function Player.parse(table)
    local id = table.id
    local nickname = table.nickname
    local state = PlayerState.parse(table.state)

    return Player.new(id, nickname, state)
end

function Player:__tostring()
    return  "id="..tostring(self.id)..
            ", nickname="..tostring(self.nickname)..
            ", state="..tostring(self.state)
end

return Player