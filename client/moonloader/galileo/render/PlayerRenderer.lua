local FontFlag = require('moonloader').font_flag
local Color = require("galileo.util.Color")
local Vector2D = require('galileo.util.Vector2D')
local Vector3D = require('galileo.util.Vector3D')

local RENDER_MIN_DISTANCE = 50

local PlayerRenderer = {}
PlayerRenderer.__index = PlayerRenderer

function PlayerRenderer.new()
    local object = setmetatable({}, PlayerRenderer)
    object.font = renderCreateFont('Verdana', 12, FontFlag.BOLD + FontFlag.SHADOW)

    return object
end

function PlayerRenderer.isPointInView(pointCoords, cameraCoords, cameraPointCoords)
    local pointVector = Vector3D.sub(pointCoords, cameraCoords)
    local normPointVector = Vector3D.normalize(pointVector)
    local cameraDirection = Vector3D.sub(cameraPointCoords, cameraCoords)
    local normCameraDirection = Vector3D.normalize(cameraDirection)
    local dotProduct = Vector3D.dot(normPointVector, normCameraDirection)
    return dotProduct > 0
end

function PlayerRenderer:renderCircle(x, y, radius, color)
    renderBegin(6)
    renderColor(color)

    renderVertex(x, y)

    for i = 0, 30 do
        local angle = math.rad((i / 30) * 360)
        local px = x + math.cos(angle) * radius
        local py = y + math.sin(angle) * radius
        renderVertex(px, py)
    end
  
    local px = x + math.cos(0) * radius
    local py = y + math.sin(0) * radius

    renderVertex(px, py)

    renderEnd()
end

function PlayerRenderer:renderPlayerMarker(coords, color)
    local a, r, g, b = Color.explode(color)
    local playerColor = Color.implode(100, r, g, b)
    local borderColor = Color.implode(100, 0, 0, 0)
    local marginColor = Color.implode(100, 255, 255, 255)

    PlayerRenderer:renderCircle(coords.x, coords.y, 11, borderColor)
    PlayerRenderer:renderCircle(coords.x, coords.y, 10, marginColor)
    PlayerRenderer:renderCircle(coords.x, coords.y, 9, borderColor)
    PlayerRenderer:renderCircle(coords.x, coords.y, 8, playerColor)
end

function PlayerRenderer:render(player)
    local playerCoords = player.state.pedCoords
    local cameraCoords = Vector3D.new(getActiveCameraCoordinates())
    local cameraPointCoords = Vector3D.new(getActiveCameraPointAt())
    local cameraToPlayerDistance = Vector3D.magnitude(Vector3D.sub(playerCoords, cameraCoords))

    if PlayerRenderer.isPointInView(playerCoords, cameraCoords, cameraPointCoords) and 
            cameraToPlayerDistance > RENDER_MIN_DISTANCE then
        local screenCoords = Vector2D.new(convert3DCoordsToScreen(playerCoords.x, playerCoords.y, playerCoords.z))

        PlayerRenderer:renderPlayerMarker(screenCoords, player.state.pedColor)
    end 
end

return PlayerRenderer