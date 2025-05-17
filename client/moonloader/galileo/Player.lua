local Player = {}
Player.__index = Player

function Player.new(id, nickname, coords, velocity, acceleration, color,
                    hp, ap, vehicle, interior, connected, afk)
    local object = setmetatable({}, Player)
    object.id = id
    object.nck = nickname
    object.crd = coords
    object.vel = velocity
    object.acc = acceleration
    object.col = color
    object.hp = hp
    object.ap = ap
    object.veh = vehicle
    object.int = interior
    object.con = connected
    object.afk = afk

    return object
end

function Player.parse(table)
    local id = table.id
    local nickname = table.nck
    local coords = table.crd
    local velocity = table.vel
    local acceleration = table.acc
    local color = table.col
    local hp = table.hp
    local ap = table.ap
    local vehicle = table.veh
    local interior = table.int
    local connected = table.con
    local afk = table.afk

    return Player.new(id, nickname, coords, velocity, acceleration, color,
                        hp, ap, vehicle, interior, connected, afk)
end

function Player:__tostring()
    return  "id="..tostring(self.id)..
            ", nck="..tostring(self.nck)..
            ", crd="..tostring(self.crd)..
            ", vel="..tostring(self.vel)..
            ", acc="..tostring(self.acc)..
            ", col="..tostring(self.col)..
            ", hp="..tostring(self.hp)..
            ", ap="..tostring(self.ap)..
            ", veh="..tostring(self.veh)..
            ", int="..tostring(self.int)..
            ", con="..tostring(self.con)..
            ", afk="..tostring(self.afk)
end

return Player