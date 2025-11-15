script_name("Update Controller")
script_author("La_Roux")
script_description("Update controller for your projects.")
script_properties("forced-reloading-only", "work-in-pause")

local http = require("socket.http")
local ltn12 = require("ltn12")
local base64 = require("base64")
local inicfg = require("inicfg")

local config = inicfg.load({
        service = {
            url = "http://127.0.0.1:6000/api",
            versionEndpointURI = "version", -- without leading slash
			commitEndpointURI = "commit" -- without leading slash
        },
		version = {
			length = 40 -- as for github sha-1
		}
    }, "updater.ini")
inicfg.save(config, "updater.ini")

local autoReloadScript = nil

local function loadProjects()
	local projectsFilePath = "moonloader/updater/projects.json"
	local projectsFile = io.open(projectsFilePath, "r")
	if not projectsFile then
		error("failed to open projects file")
	end
	
	local content = projectsFile:read("*all")
	projectsFile:close()
	
	return decodeJson(content)
end

local function saveProjects(projects)
	local projectsFilePath = "moonloader/updater/projects.json"
	local projectsFile = io.open(projectsFilePath, "w")
	if not projectsFile then
		error("failed to open projects file")
	end
	
	local content = encodeJson(projects)
	projectsFile:write(content)
	projectsFile:close()
end

-- returns current local project manifest
local function getManifest(directory)
	local manifestFilePath = "moonloader/"..directory.."/manifest"
	
	local manifestFile = io.open(manifestFilePath, "r")
	if not manifestFile then
		error("failed to open manifest file")
	end
	
	local content = manifestFile:read("*all")
	manifestFile:close()
	
	return decodeJson(content)
end

-- returns current local project version
local function getCurrentVersion(directory)
	local versionFilePath = "moonloader/"..directory.."/version"
	
	local versionFile = io.open(versionFilePath, "r")
	if not versionFile then
		error("failed to open version file")
	end
	
	local version = versionFile:read("*all")
	versionFile:close()
	
	if #version ~= config.version.length then
		error("invalid version value length")
	end
	
	return version
end

-- returns latest project version by accessing remote http service
local function getLatestVersion(name)
    -- http://127.0.0.1:6000/version/galileo - example
	local requestURL = config.service.url.."/"..config.service.versionEndpointURI.."/"..name
	local requestMethod = "GET"
	local requestHeaders = {
		["Accept"] = "application/json"
	}
	
	local response = {}
	local result, code, headers = http.request{
		url = requestURL,
		method = requestMethod,
		headers = requestHeaders,
		sink = ltn12.sink.table(response)
	}
	
	if code ~= 200 then
		error("bad response code: "..code)
	end
	
	local json = ""
	for _, value in pairs(response) do
		json = json..value
	end
	
	local data = decodeJson(json)
	if data == nil or data.version == nil then
		error("invalid response body")
	end
	
	if #data.version ~= config.version.length then
		error("invalid commit hash length: "..#data.version)
	end
	
	return data.version
end

-- returns the entire project in json-based string with base64 files encoded
-- the json repeats the actual directories and files
local function getCommit(name, hash)
	-- http://127.0.0.1:6000/commit/galileo/e83c5163316f89bfbde7d9ab23ca2e25604af290 - example
	local requestURL = config.service.url.."/"..config.service.commitEndpointURI.."/"..name.."/"..hash
	local requestMethod = "GET"
	local requestHeaders = {
		["Accept"] = "application/json"
	}
	
	local response = {}
	local result, code, headers = http.request{
		url = requestURL,
		method = requestMethod,
		headers = requestHeaders,
		sink = ltn12.sink.table(response)
	}
	
	if code ~= 200 then
		error("bad response code: "..code)
	end
	
	local json = ""
	for _, value in pairs(response) do
		json = json..value
	end
	
	local data = decodeJson(json)
	if data == nil or data.commit == nil or data.structure == nil then
		error("invalid response body")
	end
	
	if #data.commit ~= config.version.length then
		error("invalid commit hash length: "..#data.version)
	end
	
	return data.structure
end

-- creates local file structure according to 'structure' argument
local function createLocalCommit(structure)
	local function createNode(node, root)
		for name, value in pairs(node) do
			local path = root.."/"..name
			if type(value) == "string" then
				local content = base64.decode(value)
				
				local file, err = io.open(path, "wb")
				if not file then
					if not path:lower():find("%.dll") then 
						error("failed to open file "..path..": "..err)
					end
				else
					file:write(content)
					file:close()
				end
			end
			if type(value) == "table" then
				createDirectory(path)
				createNode(value, path)
			end
		end
	end
	
	createNode(structure, "moonloader")
end

-- removes local file structure according to 'structure' argument
local function removeLocalCommit(structure)
	for _, node in pairs(structure) do
		local ok, err = os.remove(node)
		if not ok then
			print("failed to delete node: "..tostring(err))
		end
	end
end

-- create version file inside project's folder with content of 'hash' argument
local function createVersionFile(directory, hash)
	local versionFilePath = "moonloader/"..directory.."/version"
	
	local versionFile = io.open(versionFilePath, "w")
	if not versionFile then
		error("failed to create file "..versionFilePath)
	end
	
	versionFile:write(hash)
	versionFile:close()
end

-- launches script by it's path
local function launchScript(path)
	local script = script.load(path)
	if not script then
		error("failed to load script "..path)
	end
end

-- terminates script execution with name 'name'
local function terminateScript(name)
	local script = script.find(name)
	if not script then
		error("failed to find script "..name)
	end
	
	script:unload()
end

local function stopAutoReload()
	local script = script.find("ML-AutoReboot")
	if script then
		autoReloadScript = script
		terminateScript(script.name)
	end
end

local function startAutoReload()
	if autoReloadScript ~= nil then
		launchScript(autoReloadScript.path)
	end
end

local function getShallowStructure(structure)
	local shallow = {}

	local function processNode(node, root)
		for name, value in pairs(node) do
			local path = root.."/"..name
			if type(value) == "string" then
				table.insert(shallow, path)
			end
			if type(value) == "table" and name ~= "lib"  then
				processNode(value, path)
				table.insert(shallow, path)
			end
		end
	end
	
	processNode(structure, "moonloader")
	
	return shallow
end

function main()
	local projects = loadProjects()
	
	for _, project in pairs(projects) do
		if project.title ~= nil and project.directory ~= nil and project.executable ~= nil then
			local title = project.title
			local directory = project.directory
			local executable = project.executable
			local files = project.structure
			
			local ok, currentVersion = pcall(function() return getCurrentVersion(directory) end)
			if not ok then
				print("failed to get current "..title.." version: "..currentVersion)
			end
	
			local ok, latestVersion = pcall(function() return getLatestVersion(title) end)
			if not ok then
				print("failed to get latest "..title.." version: "..latestVersion)
				return
			end

			if currentVersion ~= latestVersion then
				local ok, structure = pcall(function() return getCommit(title, latestVersion) end)
				if not ok then
					print("failed to download project "..title.." commit "..latestVersion..": "..structure)
					return
				end
				
				local ok, err = pcall(stopAutoReload)
				if not ok then
					print("failed to stop auto reload script: "..err)
				end
		
				local ok, err = pcall(function() terminateScript(title) end)
				if not ok then
					print("failed to terminate "..title..": "..err)
				end
		
				if files ~= nil then
					local ok, err = pcall(function() removeLocalCommit(files) end)
					if not ok then
						print("failed to remove local commit: "..err)
						return
					end
				end
		
				local ok, err = pcall(function() createLocalCommit(structure) end)
				if not ok then
					print("failed to create local commit "..latestVersion..": "..err)
					return
				end
				
				local ok, manifest = pcall(function() return getManifest(directory) end)
				if not ok then
					print("failed to read project "..title.." manifest: "..manifest)
				end
				
				local ok, shallow = pcall(function() return getShallowStructure(structure) end)
				if not ok then
					print("failed to get shallow project structure: "..shallow)
				end
	
				local ok, err = pcall(function() createVersionFile(directory, latestVersion) end)
				if not ok then
					print("failed to create version file: "..err)
					return
				end
				
				local ok, err = pcall(startAutoReload)
				if not ok then
					print("failed to start auto reload script: "..err)
				end
	
				local ok, err = pcall(function() launchScript(executable) end)
				if not ok then
					print("failed to launch "..executable..": "..err)
					return
				end
				
				if manifest then
					project.title = manifest.title == nil and title or manifest.title
					project.directory = manifest.directory == nil and directory or manifest.directory
					project.executable = manifest.executable == nil and executable or manifest.executable
				end
				project.structure = shallow
	
				print(title.." was successfully updated to "..latestVersion)
			end
		end
	end
	
	saveProjects(projects)
end