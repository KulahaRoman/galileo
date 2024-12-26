local FontFlag = require('moonloader').font_flag
local Vector2D = require('galileo.util.Vector2D')
local Vector3D = require('galileo.util.Vector3D')

local RENDER_MIN_DISTANCE = 25

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

function PlayerRenderer:render(player)
    local playerCoords = player.state.pedCoords
    local cameraCoords = Vector3D.new(getActiveCameraCoordinates())
    local cameraPointCoords = Vector3D.new(getActiveCameraPointAt())
    local cameraToPlayerDistance = Vector3D.magnitude(Vector3D.sub(playerCoords, cameraCoords))

    if PlayerRenderer.isPointInView(playerCoords, cameraCoords, cameraPointCoords) and 
            cameraToPlayerDistance > RENDER_MIN_DISTANCE then
        local screenCoords = Vector2D.new(convert3DCoordsToScreen(playerCoords.x, playerCoords.y, playerCoords.z))

        -- draw player
        renderFontDrawText(self.font, player.nickname, screenCoords.x, screenCoords.y, 0xFFFFFFFF) 
    end 
end

return PlayerRenderer