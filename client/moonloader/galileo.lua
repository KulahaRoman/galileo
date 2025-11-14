script_name("Galileo")
script_author("La_Roux")
script_description("Система координации игроков в реальном времени.")
script_properties("forced-reloading-only")

local Configuration = require("galileo.config.Configuration")
Configuration.reload()
Configuration.save();

local Player = require("galileo.Player")
local PlayerProvider = require("galileo.provider.PlayerProvider")
local PlayerIDProvider = require("galileo.provider.PlayerIDProvider")
local ServerProvider = require("galileo.provider.ServerProvider")
local InteriorProvider = require('galileo.provider.InteriorProvider')
local ConnectionStatusProvider = require("galileo.provider.ConnectionStatusProvider")
local Connector = require("galileo.network.Connector")
local Packet = require("galileo.network.Packet")
local Serializer = require("galileo.util.Serializer")
local Clock = require("galileo.util.Clock")
local Color = require("galileo.util.Color")
local Renderer = require("galileo.render.Renderer")
local values = require("galileo.util.Values")
local Vector3D = require("galileo.util.Vector3D")

local SAMP_PERIOD = Configuration.config.timing.sampPeriod
local INPUT_PERIOD = Configuration.config.timing.inputPeriod
local RENDER_PERIOD = Configuration.config.timing.renderPeriod

local networkingEnabled = true
local markerRenderingEnabled = true
local badgeRenderingEnabled = true

local previousPlayersTable = {}
local currentPlayersTable = {}
local markersPlayerTable = {}

local connection = nil

local function message(text)
    sampAddChatMessage("[GALILEO] "..text, 0xDC143C)
end

local function inputLoop()
    local networkingHotkey = Configuration.config.hotkeys.networking
    local markerRenderingHotkey = Configuration.config.hotkeys.markerRendering
    local badgeRenderingHotkey = Configuration.config.hotkeys.badgeRendering

    while true do
        -- toggle networking
        if isKeyJustPressed(networkingHotkey) and not sampIsCursorActive() then
            networkingEnabled = not networkingEnabled

            if networkingEnabled then
                message("{FFFFFF}Обмен данными {00FF00}активирован.")
            else
                message("{FFFFFF}Обмен данными {FF0000}деактивирован.")
            end
        end

        -- toggle marker rendering
        if isKeyJustPressed(markerRenderingHotkey) and not sampIsCursorActive() then
            markerRenderingEnabled = not markerRenderingEnabled

            if markerRenderingEnabled then
                message("{FFFFFF}Отображение маркеров {00FF00}активировано.")
            else
                message("{FFFFFF}Отображение маркеров {FF0000}деактивировано.")
            end
        end

        -- toggle badge rendering
        if isKeyJustPressed(badgeRenderingHotkey) and not sampIsCursorActive() then
            badgeRenderingEnabled = not badgeRenderingEnabled

            if badgeRenderingEnabled then
                message("{FFFFFF}Отображение бэйджей {00FF00}активировано.")
            else
                message("{FFFFFF}Отображение бэйджей {FF0000}деактивировано.")
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

    while networkingEnabled and markerRenderingEnabled do
        previousTimestamp = currentTimestamp
        currentTimestamp = Clock.getCurrentTimeMillis()

        local dt = currentTimestamp - previousTimestamp

        Renderer.renderBegin()

        -- perform final calculations before rendering
        for nickname, player in pairs(currentPlayersTable) do
            if player.id ~= PlayerIDProvider.getCurrentPlayerID() and previousPlayersTable[nickname] ~= nil then
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
                    local previousPacketTime = previousPlayersTable[nickname].timeUpdated
                    local currentPacketTime = currentPlayersTable[nickname].timeUpdated
                    local previousCoords = previousPlayersTable[nickname].crd
                    local currentCoords = currentPlayersTable[nickname].crd
                    local alpha = (currentPlayersTable[nickname].timeLocal - previousPacketTime) /
                                                        (currentPacketTime - previousPacketTime)
                    local coordsDifference = Vector3D.sub(currentCoords, previousCoords)
                    local coordsShift = Vector3D.multiply(coordsDifference, alpha)
                    local coordsInterpolated = Vector3D.add(previousCoords, coordsShift)
                    currentPlayersTable[nickname].timeLocal = currentPlayersTable[nickname].timeLocal + dt
                    if currentPlayersTable[nickname].timeLocal >= currentPlayersTable[nickname].timeUpdated then
                        currentPlayersTable[nickname].timeLocal = currentPlayersTable[nickname].timeUpdated
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
				
                if ConnectionStatusProvider.getCurrentStatus() and player.con and
                        InteriorProvider.getCurrentInterior() == player.int then
					-- create new player state exceptionally for rendering
					local renderPlayer = Player.new(player.id, player.nck, transformatedCoords,
													player.vel, player.acc, player.col,
													player.hp, player.ap, player.veh,
													player.int, player.con, player.afk)
						
                    -- render player's spatial marker
                    Renderer.render(renderPlayer, badgeRenderingEnabled)
					
					-- render player's map marker
					local a, r, g, b = Color.explodeARGB(renderPlayer.col)
					setBlipCoordinates(markersPlayerTable[nickname], renderPlayer.crd.x, renderPlayer.crd.y, renderPlayer.crd.z)
					changeBlipColour(markersPlayerTable[nickname], Color.implodeARGB(r,g,b, 0xFF))
                else
					removeBlip(markersPlayerTable[nickname])
					markersPlayerTable[nickname] = nil
				end				
            end
        end

        Renderer.renderEnd()

        -- yield CPU
        wait(RENDER_PERIOD)
    end
end

local function networkLoop()
    local hostname = Configuration.config.server.hostname
    local port = Configuration.config.server.port

    local conn, err = Connector.connect(hostname, port)
    if not conn then
        message("{FFFFFF}Соединение {FF0000}не установлено.")
        error("Failed to connect the server at "..hostname..":"..port..". Reason: "..err)
    end
	
	connection = conn

    message("{FFFFFF}Соединение {00FF00}установлено.")
    print("Connected to "..hostname..":"..port)

    while networkingEnabled do
        local server = ServerProvider.getCurrentServer()
        local player = PlayerProvider.getCurrentPlayer()
        local payload = Serializer.serializeObject({srv = server, plr = player})
        local packet = Packet.new(payload)

        -- send player
        local sent, err = connection:write(packet)
        if not sent then
			connection:close();
			connection = nil

            message("{FFFFFF}Соединение {FF0000}потеряно.")
            error("Failed to send data: "..err..". Connection closed.")
        end

        -- receive players
        local packet, err = connection:read()
        if not packet then
            connection:close();
			connection = nil

            message("{FFFFFF}Соединение {FF0000}потеряно.")
            error("Failed to receive data: "..err..". Connection closed.")
        end

        local packetTime = Clock.getCurrentTimeMillis()
        local playersJson = packet.payload
        local playersTable = Serializer.deserializeObject(playersJson)

        -- update previous players table
        for nickname in pairs(previousPlayersTable) do
            previousPlayersTable[nickname] = nil
        end
        for nickname, player in pairs(currentPlayersTable) do
            previousPlayersTable[nickname] = player
        end

        -- update current players table
        for nickname in pairs(currentPlayersTable) do
            currentPlayersTable[nickname] = nil
        end

        for playerTable in values(playersTable) do
            local player = Player.parse(playerTable)
			
			if markersPlayerTable[player.nck] == nil then
				local marker = addBlipForCoord(	player.crd.x, 
												player.crd.y,
												player.crd.z);
				local _, r, g, b = Color.explodeARGB(player.col)
				local color = Color.implodeARGB(r,g,b, 0xFF)
				changeBlipColour(marker, color)
				
				markersPlayerTable[player.nck] = marker
			end

            currentPlayersTable[player.nck] = player
            currentPlayersTable[player.nck].timeUpdated = packetTime -- timestamp when player data received

            -- current interpolation time for this player
            -- T(n)_local = T(n-1)_update
            -- also initialize buffer for simple average calculation for current player
            if previousPlayersTable[player.nck] ~= nil then
                currentPlayersTable[player.nck].timeLocal = previousPlayersTable[player.nck].timeUpdated

                currentPlayersTable[player.nck].bufferSize = previousPlayersTable[player.nck].bufferSize
                currentPlayersTable[player.nck].buffer = previousPlayersTable[player.nck].buffer
            else
                currentPlayersTable[player.nck].bufferSize = 20
                currentPlayersTable[player.nck].buffer = {}
            end
        end
		
		for nickname in pairs(markersPlayerTable) do
			if currentPlayersTable[nickname] == nil then
				removeBlip(markersPlayerTable[nickname])
				markersPlayerTable[nickname] = nil
			end
		end
    end

    connection:close();
	connection = nil

    message("{FFFFFF}Соединение {FF0000}закрыто.")
    print("Connection closed.")
end

local function renderThread()
    while true do
        if markerRenderingEnabled then
            local ok, err = pcall(renderLoop);
            if not ok then
                print("Error caught:", err);
            end
        end

        wait(10)
    end
end

local function networkThread()
    while true do
        if networkingEnabled then
            local ok, err = pcall(networkLoop);
            if not ok then
                print("Error caught:", err);
            end
        end

        wait(10)
    end
end

function main()
    while not isSampfuncsLoaded() or not isSampLoaded() or not isSampAvailable() do
        wait(SAMP_PERIOD)
    end

    local networkingHotkey = string.char(Configuration.config.hotkeys.networking)
    local markerRenderingHotkey = string.char(Configuration.config.hotkeys.markerRendering)
    local badgeRenderingHotkey = string.char(Configuration.config.hotkeys.badgeRendering)

    message("{FFFFFF}Для переключения обмена данными, нажмите клавишу '"..networkingHotkey.."'.")
    message("{FFFFFF}Для переключения отображения маркеров, нажмите клавишу '"..markerRenderingHotkey.."'.")
    message("{FFFFFF}Для переключения отображения бэйджей, нажмите клавишу '"..badgeRenderingHotkey.."'.")

    lua_thread.create(networkThread)
    lua_thread.create(renderThread)

    inputLoop()
end

function onScriptTerminate(script, quitGame)
	if script == script.this then
		for nickname in pairs(markersPlayerTable) do
			removeBlip(markersPlayerTable[nickname])
		end
		if connection then
			connection:close()
		end
	end
end