local Player = require("galileo.Player")
local Connector = require("galileo.network.Connector")
local Packet = require("galileo.network.Packet")
local PlayerProvider = require("galileo.provider.PlayerProvider")
local Serializer = require("galileo.util.Serializer")
local ConfigManager = require("galileo.config.ConfigManager")

local SAMP_CHECK_PERIOD = 200
local RENDER_PERIOD = 0

local function renderThread(players)
    local Renderer = require("galileo.render.PlayerRenderer")
    local values = require("galileo.util.ValuesIterator")

    local playerRenderer = Renderer.new()

    -- render loop
    while true do
        -- render players
        for player in values(players) do
            playerRenderer:render(player)
        end

        -- yield CPU
        wait(RENDER_PERIOD)
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

    local configManager = ConfigManager.new()

    local hostname = configManager.config.server.hostname
    local port = configManager.config.server.port

    local connection = Connector.connect(hostname, port)

    -- shared table (between threads)
    local players = {}

    -- launch rendering thread
    lua_thread.create(renderThread, players)

    -- main loop
    while true do
        local player = PlayerProvider.getCurrentPlayer()
        local playerJson = Serializer.serializeObject(player)
        local packet = Packet.new(playerJson)

        -- send player
        connection:write(packet)

        -- receive players
        local packet = connection:read()
        local playersJson = packet.payload
        local playersTable = Serializer.deserializeObject(playersJson)

        -- update players:
        -- clear players
        for i=1, #players do
            players[i] = nil
        end
        -- parse players
        for index, player in ipairs(playersTable) do
            players[index] = Player.parse(player)
        end
    end
end