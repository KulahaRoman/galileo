local FontFlag = require('moonloader').font_flag
local Color = require("galileo.util.Color")
local values = require('galileo.util.Values')
local Vector2D = require('galileo.util.Vector2D')
local Vector3D = require('galileo.util.Vector3D')

local SCREEN_WIDTH, SCREEN_HEIGHT = getScreenResolution()
local SCREEN_CENTER_X = SCREEN_WIDTH / 2
local SCREEN_CENTER_Y = SCREEN_HEIGHT / 2
local FONT = renderCreateFont('Segoe UI Semibold', SCREEN_WIDTH * 0.004)

local vehicles = {
    airplane   = { 592, 577, 511, 512, 593, 520, 553, 476, 519, 460, 513 },
    helicopter = { 548, 425, 417, 487, 488, 497, 563, 447, 469 },
    boat       = { 472, 473, 493, 595, 484, 430, 453, 452, 446, 454 },
    moto       = { 581, 521, 463, 522, 462, 461, 448, 468, 586, 471 },
    bike       = { 509, 481, 510 },
    train      = { 590, 538, 570, 569, 537, 449 }
}

local icons = {
    airplane = renderLoadTextureFromFile("moonloader/galileo/resources/icons/airplane.png"),
    helicopter = renderLoadTextureFromFile("moonloader/galileo/resources/icons/helicopter.png"),
    boat = renderLoadTextureFromFile("moonloader/galileo/resources/icons/boat.png"),
    moto = renderLoadTextureFromFile("moonloader/galileo/resources/icons/moto.png"),
    bike = renderLoadTextureFromFile("moonloader/galileo/resources/icons/bike.png"),
    train = renderLoadTextureFromFile("moonloader/galileo/resources/icons/train.png"),
    ped = renderLoadTextureFromFile("moonloader/galileo/resources/icons/ped.png"),
    car = renderLoadTextureFromFile("moonloader/galileo/resources/icons/car.png")
}

local Renderer = {}
Renderer.__index = Renderer

local markers = {}
local badges = {}

local function clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

local function formatNickname(nickname)
    local first, second = nickname:match("([^_]+)_([^_]+)")
    if first and second then
        return first:sub(1, 1) .. "." .. second
    end
    return nickname
end

local function vehicleType(id)
    if id == -1 then
        return "ped"
    end

    for type, ids in pairs(vehicles) do
        for i in values(ids) do
            if i == id then
                return type
            end
        end
    end

    return "car"
end

local function intersect(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and
           ax + aw > bx and
           ay < by + bh and
           ay + ah > by
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

local function renderLine(x0, y0, x1, y1, color)
    renderBegin(2)
    renderColor(color)

    renderVertex(x0, y0)
    renderVertex(x1, y1)

    renderEnd()
end

local function renderThickLine(x0, y0, x1, y1, thickness, color)
    local dx, dy = x1 - x0, y1 - y0
    local length = math.sqrt(dx * dx + dy * dy)

    local nx, ny = dx / length, dy / length

    local px, py = -ny * thickness / 2, nx * thickness / 2

    local x2, y2 = x1 + px, y1 + py
    local x3, y3 = x1 - px, y1 - py
    local x4, y4 = x0 - px, y0 - py
    local x5, y5 = x0 + px, y0 + py

    renderBegin(5)
    renderColor(color)

    renderVertex(x5, y5)
    renderVertex(x2, y2)
    renderVertex(x3, y3)

    renderVertex(x5, y5)
    renderVertex(x3, y3)
    renderVertex(x4, y4)

    renderEnd()
end

local function renderText(x, y, text, font, color)
    renderFontDrawText(font, text, x, y, color)
end

local function renderMarker(marker)
    local a, r, g, b = Color.explode(marker.player.col)

    local playerAlpha = 200 * marker.alpha
    if marker.player.afk then
        playerAlpha = playerAlpha / 5
    end

    local borderAlpha = 200 * marker.alpha
    local marginAlpha = 200 * marker.alpha

    local playerColor = Color.implode(playerAlpha, r, g, b)
    local borderColor = Color.implode(borderAlpha, 0, 0, 0)
    local marginColor = Color.implode(marginAlpha, 255, 255, 255)

    local circleRadius = marker.radius
    local innerBorderRadius = circleRadius + 0.5
    local marginMinRingRadius = innerBorderRadius + 0.5
    local marginMaxRingRadius = marginMinRingRadius + 2.75
    local outterBorderRadius = marginMaxRingRadius + 0.25

    renderCircumference(marker.coords.x, marker.coords.y, outterBorderRadius, borderColor)
    renderRing(marker.coords.x, marker.coords.y, marginMinRingRadius, marginMaxRingRadius, marginColor)
    renderCircumference(marker.coords.x, marker.coords.y, innerBorderRadius, borderColor)
    renderCircle(marker.coords.x, marker.coords.y, circleRadius, playerColor)
end

local function renderBadge(badge)
    local fillColor = Color.implode(200 * badge.alpha, 255, 255 ,255)
    local outlineColor = Color.implode(200 * badge.alpha, 0, 0 ,0)
    local iconColor = Color.implode(255 * badge.alpha, 0, 0 ,0)
    local textColor = Color.implode(255 * badge.alpha, 0, 0 ,0)

    renderRectangle(badge.coords.x, badge.coords.y, badge.coords.x + badge.size.width,
                    badge.coords.y + badge.size.height, fillColor)
    renderLine(badge.coords.x, badge.coords.y, badge.coords.x + badge.size.width,
                badge.coords.y, outlineColor)
    renderLine(badge.coords.x, badge.coords.y + badge.size.height, badge.coords.x + badge.size.width,
                badge.coords.y + badge.size.height, outlineColor)
    renderLine(badge.coords.x + badge.size.width, badge.coords.y, badge.coords.x + badge.size.width,
                badge.coords.y + badge.size.height, outlineColor)
    renderLine(badge.coords.x, badge.coords.y, badge.coords.x,
                badge.coords.y + badge.size.height / 2 - 1, outlineColor)
    renderLine(badge.coords.x, badge.coords.y + badge.size.height / 2 + 1, badge.coords.x,
                badge.coords.y + badge.size.height, outlineColor)

    renderThickLine(badge.coords.x - SCREEN_WIDTH * 0.005, badge.coords.y + badge.size.height / 2,
                badge.coords.x, badge.coords.y + badge.size.height / 2, 2, fillColor)

    local dx, dy = badge.coords.x - badge.marker.coords.x, badge.coords.y + badge.size.height / 2 - badge.marker.coords.y
    local length = math.sqrt(dx * dx + dy * dy)

    local nx, ny = dx / length, dy / length

    local startX = badge.marker.coords.x + nx * (badge.marker.radius + 3)
    local startY = badge.marker.coords.y + ny * (badge.marker.radius + 3)

    renderThickLine(startX, startY, badge.coords.x - SCREEN_WIDTH * 0.005,
                badge.coords.y + badge.size.height / 2, 2, fillColor)

    local vehicle = vehicleType(badge.marker.player.veh)
    local icon = icons[vehicle]
    renderDrawTexture(icon, badge.coords.x + badge.size.width * 0.07, badge.coords.y + badge.size.height * 0.1,
                        badge.size.height, badge.size.height - badge.size.height * 0.1, 0, iconColor)

    renderText(badge.coords.x + 34, badge.coords.y + badge.size.height * 0.15,
                badge.marker.player.nck, FONT, textColor)
end

function Renderer.renderBegin()
    markers = {}
    badges = {}
end

function Renderer.render(player, renderBadge)
    local playerCoords = player.crd
    local cameraCoords = Vector3D.new(getActiveCameraCoordinates())
    local cameraPointCoords = Vector3D.new(getActiveCameraPointAt())
    local cameraToPlayerDistance = Vector3D.magnitude(Vector3D.sub(playerCoords, cameraCoords))

    if isPointInView(playerCoords, cameraCoords, cameraPointCoords) then
        local screenCoords = Vector2D.new(convert3DCoordsToScreen(playerCoords.x, playerCoords.y, playerCoords.z))
        player.nck = formatNickname(player.nck)

        local dx = screenCoords.x - SCREEN_CENTER_X
        local dy = screenCoords.y - SCREEN_CENTER_Y

        local ndx = dx / SCREEN_CENTER_X
        local ndy = dy / SCREEN_CENTER_Y

        local normScreenDistance = math.sqrt(ndx * ndx + ndy * ndy)
        local screenFadeStart = 0.5
        local screenFadeEnd = 0.8
        local screenAlpha = 1.0 - clamp((normScreenDistance - screenFadeStart) / (screenFadeEnd - screenFadeStart), 0.0, 1.0)

        local distanceFadeStart = 50
        local distanceFadeEnd = 25
        local distanceAlpha = clamp((cameraToPlayerDistance - distanceFadeEnd) / (distanceFadeStart - distanceFadeEnd), 0.0, 1.0)

        local alpha = math.min(screenAlpha, distanceAlpha)

        local scale = 1 - (cameraToPlayerDistance / 3000)
        if scale < 0.4 then
            scale = 0.4
        end
        if scale > 1.0 then
            scale = 1.0
        end

        local marker = {}
        marker.player = player
        marker.radius = SCREEN_WIDTH * 0.005 * scale
        marker.distance = cameraToPlayerDistance
        marker.coords = screenCoords
        marker.alpha = alpha

        table.insert(markers, marker)

        if renderBadge then
            local size = {}
            size.width = renderGetFontDrawTextLength(FONT, player.nck) + SCREEN_WIDTH * 0.02
            size.height = renderGetFontDrawHeight(FONT) + SCREEN_HEIGHT * 0.005;

            local spacing =  SCREEN_HEIGHT * 0.003

            local posX = marker.coords.x + SCREEN_WIDTH * 0.013
            local posY = marker.coords.y - size.height / 2

            for badge in values(badges) do
                if intersect(badge.coords.x, badge.coords.y, badge.size.width, badge.size.height,
                                posX, posY, size.width, size.height) then
                    posY = posY - (posY - badge.coords.y) - spacing - badge.size.height
                end
            end

            local badge = {}
            badge.marker = marker
            badge.size = size
            badge.coords = Vector2D.new(posX, posY)
            badge.alpha = alpha

            table.insert(badges, badge)
        end
    end
end

function Renderer.renderEnd()
    for marker in values(markers) do
        renderMarker(marker)
    end
    for badge in values(badges) do
        renderBadge(badge)
    end
end

return Renderer