-- --著者: Wicky

local File = CS.System.IO.File
local Directory = CS.System.IO.Directory
local Path = CS.System.IO.Path
local Assembly = CS.System.Reflection.Assembly

local parentDir = nil
local ini_parser = require("tools\\ini_parser.lua")

local settingsDir = nil
local settings = nil

local allModules = {}
local modules = {}
local scripts = {}
local paths = {}

local function loadAllScripts()
	local files = Directory.GetDirectories(Path.Combine(parentDir, "modules"));

	for i = 0, files.Length - 1 do
		local path = Path.Combine(files[i], "core.lua")
		if File.Exists(path) then
			local folderName = Path.GetFileNameWithoutExtension(files[i])

			if folderName ~= "Settings" then
				table.insert(allModules, folderName)
			end

			if settings[folderName] ~= nil and settings[folderName].enable == 1 then
				local script = require(path)
				table.insert(paths, path)

				if script ~= nil and script.active == true then
					script.GetOption  = function(key)
						if settings[folderName] == nil then
							return nil
						end
						return settings[folderName][key]
					end
					script.SetOption  = function(key, value)
						if settings[folderName] == nil then
							settings[folderName] = {}
						end
						settings[folderName][key] = value
					end
					script.SaveOption = function()
						ini_parser.save(settingsDir, settings)
					end
					table.insert(modules, files[i])
					table.insert(scripts, script)
				end
			end
		end
	end

	print("Loaded " .. #scripts .. " scripts")
	util.InsertModules(allModules)
end

function onloaded()
	local platform = APPMAN:GetPlatformInt()

	if platform == 3 or platform == 4 then
		parentDir = CS.UnityEngine.Application.persistentDataPath .. "/GlobalLua/DankaguLike_GLWickyPack/"
	else
		parentDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) .. "\\GlobalLua\\DankaguLike_GLWickyPack\\"
	end

	util = require("tools\\utils.lua")
	settingsDir = parentDir .. "settings.ini"
	settings = ini_parser.load(settingsDir);

	util.InsertParentDir(parentDir)
	util.InsertSettings(ini_parser, settingsDir)
	loadAllScripts()

	for i = 1, #scripts do
		scripts[i].LoadTexture = function(asset)
			return UTIL:LoadTexture(modules[i] .. "\\" .. asset)
		end
		scripts[i].LoadAssetBundle = function(asset)
			return ASSETMAN:LoadAssetBundle(modules[i] .. "\\" .. asset)
		end
		if scripts[i].onloaded == nil then goto continue end
		scripts[i].onloaded()
		::continue::
	end
end

function start()
	local canvas = util.GetCanvas()
	local canvasComp = canvas:GetComponent(typeof(CS.UnityEngine.Canvas))
	canvasComp.renderMode = CS.UnityEngine.RenderMode.ScreenSpaceOverlay
	canvasComp.sortingOrder = 5

	for i = 1, #scripts do
		if scripts[i].start == nil then goto continue end
		scripts[i].start()
		::continue::
	end
end

function update()
	for i = 1, #scripts do
		if scripts[i].update == nil then goto continue end
		scripts[i].update()
		::continue::
	end
end

function finish()
	for i = 1, #scripts do
		if scripts[i].finish == nil then goto continue end
		scripts[i].finish()
		::continue::
	end
end

function onHitNote(id, lane, noteType, judgeType, isAttack)
	for i = 1, #scripts do
		if scripts[i].onHitNote == nil then goto continue end
		scripts[i].onHitNote(id, lane, noteType, judgeType, isAttack)
		::continue::
	end
end

function onMissedNote(id, lane, noteType)
	for i = 1, #scripts do
		if scripts[i].onMissedNote == nil then goto continue end
		scripts[i].onMissedNote(id, lane, noteType)
		::continue::
	end
end

function onSpawnNote(noteController)
	for i = 1, #scripts do
		if scripts[i].onSpawnNote == nil then goto continue end
		scripts[i].onSpawnNote(noteController)
		::continue::
	end
end

function onSpawnLong(longController)
	for i = 1, #scripts do
		if scripts[i].onSpawnLong == nil then goto continue end
		scripts[i].onSpawnLong(longController)
		::continue::
	end
end

function onPause()
	for i = 1, #scripts do
		if scripts[i].onPause == nil then goto continue end
		scripts[i].onPause()
		::continue::
	end
end

function onResume()
	for i = 1, #scripts do
		if scripts[i].onResume == nil then goto continue end
		scripts[i].onResume()
		::continue::
	end
end

function onInputDown(touchId, posX, screenPosX, screenPosY)
	for i = 1, #scripts do
		if scripts[i].onInputDown == nil then goto continue end
		scripts[i].onInputDown(touchId, posX, screenPosX, screenPosY)
		::continue::
	end
end

function onInputMove(touchId, posX, screenPosX, screenPosY)
	for i = 1, #scripts do
		if scripts[i].onInputMove == nil then goto continue end
		scripts[i].onInputMove(touchId, posX, screenPosX, screenPosY)
		::continue::
	end
end

function onInputUp(touchId, posX, screenPosX, screenPosY)
	for i = 1, #scripts do
		if scripts[i].onInputUp == nil then goto continue end
		scripts[i].onInputUp(touchId, posX, screenPosX, screenPosY)
		::continue::
	end
end

function finish()
	for i = 1, #scripts do
		if scripts[i].finish == nil then goto continue end
		scripts[i].finish()
		::continue::
	end
end

function ondestroy()
	for i = 1, #scripts do
		if scripts[i].ondestroy == nil then goto continue end
		scripts[i].ondestroy()
		::continue::
	end

	for _, path in ipairs(paths) do
		package.loaded[path] = nil
	end

	for _, path in ipairs(paths) do
		_G[path] = nil
	end

	package.loaded['tools\\utils.lua'] = nil
	_G['tools\\utils.lua'] = nil

	package.loaded['tools\\ini_parser.lua'] = nil
	_G['tools\\ini_parser.lua'] = nil
end
