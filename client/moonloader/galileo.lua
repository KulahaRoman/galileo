local Player = require("galileo.Player")
local PlayerIDProvider = require("galileo.provider.PlayerIDProvider")
local Connector = require("galileo.network.Connector")
local Packet = require("galileo.network.Packet")
local PlayerProvider = require("galileo.provider.PlayerProvider")
local Serializer = require("galileo.util.Serializer")
local Clock = require("galileo.util.Clock")
local ConfigManager = require("galileo.config.ConfigManager")
local Renderer = require("galileo.render.PlayerRenderer")
local values = require("galileo.util.ValuesIterator")
local Vector3D = require("galileo.util.Vector3D")

local configManager = ConfigManager.new()
local playerRenderer = Renderer.new()

local SAMP_CHECK_PERIOD = configManager.config.timing.sampCheckPeriod
local INPUT_PERIOD = configManager.config.timing.inputPeriod
local RENDER_PERIOD = configManager.config.timing.renderPeriod

local networkingEnabled = true
local renderingEnabled = true

local previousPlayersTable = {}
local currentPlayersTable = {}

local function userNotify(text)
    sampAddChatMessage("[GALILEO] "..text, 0xDC143C)
end

local function inputLoop()
    local networkingHotkey = configManager.config.hotkeys.networking
    local renderingHotkey = configManager.config.hotkeys.rendering

    while true do
        -- toggle networking
        if isKeyJustPressed(networkingHotkey) and not sampIsCursorActive() then
            networkingEnabled = not networkingEnabled

            if networkingEnabled then
                userNotify("{FFFFFF}Обмен данными {00FF00}активирован.")
            else
                userNotify("{FFFFFF}Обмен данными {FF0000}деактивирован.")
            end
        end

        -- toggle rendering
        if isKeyJustPressed(renderingHotkey) and not sampIsCursorActive() then
            renderingEnabled = not renderingEnabled

            if renderingEnabled then
                userNotify("{FFFFFF}Отображение маркеров {00FF00}активировано.")
            else
                userNotify("{FFFFFF}Отображение маркеров {FF0000}деактивировано.")
            end
        end

        -- yield CPU
        wait(INPUT_PERIOD)
    end
end

local function renderLoop()
    -- values for calculating time difference betweeen frames
    local previousTimestamp = 0
    local currentTimestamp = 0

    while networkingEnabled and renderingEnabled do
        previousTimestamp = currentTimestamp
        currentTimestamp = Clock.getCurrentTimeMillis()

        local dt = currentTimestamp - previousTimestamp

        -- perform final calculations before rendering
        for id, player in pairs(currentPlayersTable) do
            if  id ~= PlayerIDProvider.getCurrentPlayerID() and previousPlayersTable[id] ~= nil then
                -- current player coordinates value after transformation
                local transformatedCoords = nil

                -- current player's buffer for simple average
                local bufferSize = player.bufferSize
                local buffer = player.buffer

                local result, ped = sampGetCharHandleBySampPlayerId(id)
                if result then -- if player is in stream distance, we can obtain his coordinates directly
                    local actualCoordinates = Vector3D.new(getCharCoordinates(ped))

                    -- if current player's actual coordinates are used, then we don't populate buffer,
                    -- but descrease it's size frame by frame to reduce "marker latency" to zero,
                    -- so eventually the marker will point at actual coordinates:

                    -- descrease buffer size by removing first value
                    if #buffer > 0 then
                        table.remove(buffer, 1)
                    end

                    -- calculate summ of available buffer values
                    local bufferSumm = Vector3D.new(0, 0, 0)
                    for vector in values(buffer) do
                        bufferSumm = Vector3D.add(bufferSumm, vector)
                    end

                    -- add current actual coordinates
                    bufferSumm = Vector3D.add(bufferSumm, actualCoordinates)

                    -- result of transformation is average coordinates
                    transformatedCoords = Vector3D.divide(bufferSumm, #buffer + 1)
                else -- otherwise do interpolation
                    local previousPacketTime = previousPlayersTable[id].timeUpdated
                    local currentPacketTime = currentPlayersTable[id].timeUpdated

                    local previousCoords = previousPlayersTable[id].state.pedCoords
                    local currentCoords = currentPlayersTable[id].state.pedCoords

                    local alpha = (currentPlayersTable[id].timeLocal - previousPacketTime) /
                                                        (currentPacketTime - previousPacketTime)
                    local coordsDifference = Vector3D.sub(currentCoords, previousCoords)
                    local coordsShift = Vector3D.multiply(coordsDifference, alpha)
                    local coordsInterpolated = Vector3D.add(previousCoords, coordsShift)

                    currentPlayersTable[id].timeLocal = currentPlayersTable[id].timeLocal + dt
                    if currentPlayersTable[id].timeLocal >= currentPlayersTable[id].timeUpdated then
                        currentPlayersTable[id].timeLocal = currentPlayersTable[id].timeUpdated
                    end

                    -- update buffer with new coord value
                    table.insert(buffer, coordsInterpolated)
                    if #buffer > bufferSize then
                        table.remove(buffer, 1)
                    end

                    -- calculate current average value
                    local bufferSumm = Vector3D.new(0, 0, 0)
                    for vector in values(buffer) do
                        bufferSumm = Vector3D.add(bufferSumm, vector)
                    end

                    -- result of transformation is average coordinates
                    transformatedCoords = Vector3D.divide(bufferSumm, #buffer)
                end
    
                -- create new player state exceptionally for rendering
                local playerState = {}
                playerState.pedState = currentPlayersTable[id].state.pedState
                playerState.pedCoords = transformatedCoords
                playerState.pedVelocity = currentPlayersTable[id].state.pedVelocity
                playerState.pedAcceleration = currentPlayersTable[id].state.pedAcceleration
                playerState.pedColor = currentPlayersTable[id].state.pedColor
                playerState.pedHP = currentPlayersTable[id].state.pedHP
                playerState.pedAP = currentPlayersTable[id].state.pedAP

                -- render player
                playerRenderer:render(Player.new(player.id, player.nickname, playerState))
            end
        end

        -- yield CPU
        wait(RENDER_PERIOD)
    end
end

local function networkLoop()
    local hostname = configManager.config.server.hostname
    local port = configManager.config.server.port

    local connection = Connector.connect(hostname, port)
    if not connection then
        userNotify("{FF0000}Соединение не установлено.")
        error("Failed to connect the server at "..hostname..":"..port)
    end

    userNotify("{00FF00}Соединение установлено.")
    print("Connected to "..hostname..":"..port)

    while networkingEnabled do
        local player = PlayerProvider.getCurrentPlayer()
        local playerJson = Serializer.serializeObject(player)
        local packet = Packet.new(playerJson)

        -- send player
        connection:write(packet)

        -- receive players
        local packet = connection:read()
        if not packet then
            connection:close()
            userNotify("{FF0000}Соединение потеряно.")
            error("Failed to receive data. Connection closed.")
        end

        local packetTime = Clock.getCurrentTimeMillis()
        local playersJson = packet.payload
        local playersTable = Serializer.deserializeObject(playersJson)

        -- update previous players table
        for id in pairs(previousPlayersTable) do
            previousPlayersTable[id] = nil
        end
        for id, player in pairs(currentPlayersTable) do
            previousPlayersTable[id] = player
        end

        -- update current players table
        for id in pairs(currentPlayersTable) do
            currentPlayersTable[id] = nil
        end
        for playerTable in values(playersTable) do
            local player = Player.parse(playerTable)

            currentPlayersTable[player.id] = player
            currentPlayersTable[player.id].timeUpdated = packetTime -- timestamp when player data received

            -- current interpolation time for this player
            -- T(n)_local = T(n-1)_update
            -- also initialize buffer for simple average calculation for current player
            if previousPlayersTable[player.id] ~= nil then
                currentPlayersTable[player.id].timeLocal = previousPlayersTable[player.id].timeUpdated

                currentPlayersTable[player.id].bufferSize = previousPlayersTable[player.id].bufferSize
                currentPlayersTable[player.id].buffer = previousPlayersTable[player.id].buffer
            else
                currentPlayersTable[player.id].bufferSize = 20
                currentPlayersTable[player.id].buffer = {}
            end
        end
    end

    -- clear previous players table
    for id in pairs(previousPlayersTable) do
        previousPlayersTable[id] = nil
    end

    -- clear current players table
    for id in pairs(currentPlayersTable) do
        currentPlayersTable[id] = nil
    end

    -- close connection
    connection:close()
end

local function renderThread()
    while true do
        if renderingEnabled then
            renderLoop()
        end

        wait(10)
    end
end

local function networkThread()
    while true do
        if networkingEnabled then
            networkLoop()
        end

        wait(10)
    end
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then
        error("SampFuncs is not available.")
        return
    end

    while not isSampAvailable() do
        wait(SAMP_CHECK_PERIOD)
    end

    local networkingHotkey = string.char(configManager.config.hotkeys.networking)
    local renderingHotkey = string.char(configManager.config.hotkeys.rendering)

    userNotify("{FFFFFF}Скрипт успешно загружен.")
    userNotify("{FFFFFF}Для переключения обмена данными, нажмите клавишу '"..networkingHotkey.."'.")
    userNotify("{FFFFFF}Для переключения отображения маркеров, нажмите клавишу '"..renderingHotkey.."'.")

    lua_thread.create(networkThread)
    lua_thread.create(renderThread)

    inputLoop()
end