local PlayerState = require("galileo.PlayerState")

local Player = {}
Player.__index = Player

function Player.new(nickname, state)
    local object = setmetatable({}, Player)
    object.nickname = nickname
    object.state = state

    return object
end

function Player.parse(table)
    local nickname = table.nickname
    local state = PlayerState.parse(table.state)

    return Player.new(nickname, state)
end

function Player:__tostring()
    return  "nickname="..tostring(self.nickname)..
            ", state="..tostring(self.state)
end

return Player