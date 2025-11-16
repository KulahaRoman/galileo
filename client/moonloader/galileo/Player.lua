local Player = {}
Player.__index = Player

function Player.new(id, nickname, coords, velocity, acceleration, color,
                    hp, ap, vehicleModel, vehicleID, vehicleSeat, interior, connected, afk)
    local object = setmetatable({}, Player)
    object.id = id
    object.nck = nickname
    object.crd = coords
    object.vel = velocity
    object.acc = acceleration
    object.col = color
    object.hp = hp
    object.ap = ap
    object.vehm = vehicleModel
    object.vehi = vehicleID
    object.vehs = vehicleSeat
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
    local vehicleModel = table.vehm
    local vehicleID = table.vehi
    local vehicleSeat = table.vehs
    local interior = table.int
    local connected = table.con
    local afk = table.afk

    return Player.new(id, nickname, coords, velocity, acceleration, color,
                        hp, ap, vehicleModel, vehicleID, vehicleSeat, interior, connected, afk)
end

return Player