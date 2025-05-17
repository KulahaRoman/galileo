local FontFlag = require('moonloader').font_flag
local Color = require("galileo.util.Color")
local Vector2D = require('galileo.util.Vector2D')
local Vector3D = require('galileo.util.Vector3D')

--local FONT = renderCreateFont('Verdana', 12, FontFlag.BOLD + FontFlag.SHADOW)
local SCREEN_WIDTH, SCREEN_HEIGHT = getScreenResolution()
local SCREEN_CENTER_X = SCREEN_WIDTH / 2
local SCREEN_CENTER_Y = SCREEN_HEIGHT / 2

local Renderer = {}
Renderer.__index = Renderer

local function clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

local function isPointInView(pointCoords, cameraCoords, cameraPointCoords)
    local pointVector = Vector3D.sub(pointCoords, cameraCoords)
    local normPointVector = Vector3D.normalize(pointVector)
    local cameraDirection = Vector3D.sub(cameraPointCoords, cameraCoords)
    local normCameraDirection = Vector3D.normalize(cameraDirection)
    local dotProduct = Vector3D.dot(normPointVector, normCameraDirection)
    return dotProduct > 0
end

local function renderRing(x, y, inner, outter, color)
    renderBegin(4)
    renderColor(color)

    local sectionNumber = 30
    local sectionSize = 360 / sectionNumber
    for i = 1, sectionNumber do
        local beginAngle = math.rad(sectionSize * (i - 1))
        local endAngle = math.rad(sectionSize * i)

        local ax = x + math.cos(beginAngle) * inner
        local ay = y + math.sin(beginAngle) * inner

        local bx = x + math.cos(beginAngle) * outter
        local by = y + math.sin(beginAngle) * outter

        local cx = x + math.cos(endAngle) * inner
        local cy = y + math.sin(endAngle) * inner

        local dx = x + math.cos(endAngle) * outter
        local dy = y + math.sin(endAngle) * outter

        renderVertex(ax, ay)
        renderVertex(bx, by)
        renderVertex(dx, dy)

        renderVertex(ax, ay)
        renderVertex(dx, dy)
        renderVertex(cx, cy)
    end

    renderEnd()
end

local function renderCircle(x, y, radius, color)
    renderBegin(4)
    renderColor(color)

    local sectionNumber = 30
    local sectionSize = 360 / sectionNumber
    for i = 1, sectionNumber do
        local beginAngle = math.rad(sectionSize * (i - 1))
        local endAngle = math.rad(sectionSize * i)

        local ax = x + math.cos(beginAngle) * radius
        local ay = y + math.sin(beginAngle) * radius

        local bx = x + math.cos(endAngle) * radius
        local by = y + math.sin(endAngle) * radius

        renderVertex(x, y)
        renderVertex(ax, ay)
        renderVertex(bx, by)
    end

    renderEnd()
end

local function renderCircumference(x, y, radius, color)
    renderBegin(2)
    renderColor(color)

    local sectionNumber = 30
    local sectionSize = 360 / sectionNumber
    for i = 1, sectionNumber do
        local beginAngle = math.rad(sectionSize * (i - 1))
        local endAngle = math.rad(sectionSize * i)

        local ax = x + math.cos(beginAngle) * radius
        local ay = y + math.sin(beginAngle) * radius

        local bx = x + math.cos(endAngle) * radius
        local by = y + math.sin(endAngle) * radius

        renderVertex(ax, ay)
        renderVertex(bx, by)
    end

    renderEnd()
end

local function renderRectangle(x0, y0, x1, y1, color)
    renderBegin(4)
    renderColor(color)

    local ax = x0
    local ay = y1

    local bx = x0
    local by = y0

    local cx = x1
    local cy = y0

    local dx = x1
    local dy = y1

    renderVertex(ax, ay)
    renderVertex(bx, by)
    renderVertex(dx, dy)

    renderVertex(bx, by)
    renderVertex(cx, cy)
    renderVertex(dx, dy)

    renderEnd()
end

local function renderText(x, y, text, font, color)
    renderFontDrawText(font, text, x, y, color)
end

local function renderMarker(coords, distance, player)
    local dx = coords.x - SCREEN_CENTER_X
    local dy = coords.y - SCREEN_CENTER_Y

    local ndx = dx / SCREEN_CENTER_X
    local ndy = dy / SCREEN_CENTER_Y

    local normScreenDistance = math.sqrt(ndx * ndx + ndy * ndy)
    local screenFadeStart = 0.4
    local screenFadeEnd = 1.0
    local screenAlpha = 1.0 - clamp((normScreenDistance - screenFadeStart) / (screenFadeEnd - screenFadeStart), 0.0, 1.0)

    local distanceFadeStart = 50
    local distanceFadeEnd = 25
    local distanceAlpha = clamp((distance - distanceFadeEnd) / (distanceFadeStart - distanceFadeEnd), 0.0, 1.0)

    local alpha = math.min(screenAlpha, distanceAlpha)

    local a, r, g, b = Color.explode(player.col)

    local playerAlpha = 165 * alpha
    if player.afk then
        playerAlpha = playerAlpha / 4
    end

    local borderAlpha = 165 * alpha
    local marginAlpha = 165 * alpha

    local playerColor = Color.implode(playerAlpha, r, g, b)
    local borderColor = Color.implode(borderAlpha, 0, 0, 0)
    local marginColor = Color.implode(marginAlpha, 255, 255, 255)

    local scale = 1 - (distance / 3000)
    if scale < 0.45 then
        scale = 0.45
    end
    if scale > 1.0 then
        scale = 1.0
    end

    local circleRadius = 10 * scale
    local innerBorderRadius = circleRadius + 0.25
    local marginMinRingRadius = innerBorderRadius + 0.25
    local marginMaxRingRadius = marginMinRingRadius + 2.75
    local outterBorderRadius = marginMaxRingRadius + 0.25

    renderCircumference(coords.x, coords.y, outterBorderRadius, borderColor)
    renderRing(coords.x, coords.y, marginMinRingRadius, marginMaxRingRadius, marginColor)
    renderCircumference(coords.x, coords.y, innerBorderRadius, borderColor)
    renderCircle(coords.x, coords.y, circleRadius, playerColor)
end

function Renderer.render(player)
    local playerCoords = player.crd
    local cameraCoords = Vector3D.new(getActiveCameraCoordinates())
    local cameraPointCoords = Vector3D.new(getActiveCameraPointAt())
    local cameraToPlayerDistance = Vector3D.magnitude(Vector3D.sub(playerCoords, cameraCoords))

    if isPointInView(playerCoords, cameraCoords, cameraPointCoords) then
        local screenCoords = Vector2D.new(convert3DCoordsToScreen(playerCoords.x, playerCoords.y, playerCoords.z))

        renderMarker(screenCoords, cameraToPlayerDistance, player)
    end
end

return Renderer