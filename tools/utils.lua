--著者: Wicky

util = {}

local dkjson = require("tools//dkjson.lua")
local UnityEngine = CS.UnityEngine
local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color
local Time = UnityEngine.Time
local Material = UnityEngine.Material
local Input = UnityEngine.Input
local Resources = UnityEngine.Resources
local Font = UnityEngine.Font
local Path = CS.System.IO.Path
local File = CS.System.IO.File
local WickyCanvas = nil
local width = SCREENMAN:GetScreenWidth()
local height = SCREENMAN:GetScreenHeight()
local FontJP = nil
local modules = {}

local ini_parser = nil
local parentDir = nil
local settings = nil
local settingsDir = nil
local lang = "en" --default

local stringList = {}

util.GetScreenWidth = function()
	return width
end

util.GetScreenHeight = function()
	return height
end

util.SetLanguage = function(language)
	lang = language
	local langFile = parentDir .. "lang\\" .. lang .. ".json"
	stringList = dkjson.decode(File.ReadAllText(langFile))
end

util.GetLanguage = function()
	return lang
end

util.GetStringList = function()
	return stringList
end

util.GetString = function(key)
	return stringList[key]
end

util.GetCanvas = function()
	if WickyCanvas == nil then
		WickyCanvas = UnityEngine.GameObject("WickyPackCanvas")
		local WickyCanvasComp = WickyCanvas:AddComponent(typeof(UnityEngine.Canvas))
		local WickyCanvasScale = WickyCanvas:AddComponent(typeof(UnityEngine.UI.CanvasScaler))
		WickyCanvasComp.planeDistance = 1
		WickyCanvasComp.worldCamera = CAMERAMAN:GetCamera()
		WickyCanvasComp.renderMode = UnityEngine.RenderMode.ScreenSpaceCamera
		WickyCanvasComp.sortingOrder = 5
		WickyCanvasScale.uiScaleMode = UnityEngine.UI.CanvasScaler.ScaleMode.ScaleWithScreenSize
		WickyCanvasScale.referenceResolution = Vector2(1920, 1080)
		WickyCanvasScale.matchWidthOrHeight = 1

	end
	return WickyCanvas
end

util.CreateCanvas = function(name, distance)
	local WickyCanvasTE = GameObject(name)
	local WickyCanvasTEComp = WickyCanvasTE:AddComponent(typeof(UnityEngine.Canvas))
	local WickyCanvasTEScale = WickyCanvasTE:AddComponent(typeof(UnityEngine.UI.CanvasScaler))
	WickyCanvasTEComp.planeDistance = distance
	WickyCanvasTEComp.worldCamera = CAMERAMAN:GetCamera()
	WickyCanvasTEComp.renderMode = UnityEngine.RenderMode.ScreenSpaceCamera
	WickyCanvasTEScale.uiScaleMode = UnityEngine.UI.CanvasScaler.ScaleMode.ScaleWithScreenSize
	WickyCanvasTEScale.referenceResolution = Vector2(1920, 1080)
	WickyCanvasTEScale.matchWidthOrHeight = 1
	--Refresh
	WickyCanvasTEComp.enabled = false
	WickyCanvasTEComp.enabled = true

	return WickyCanvasTE
end

util.GetFontJP = function()
	local obj = Resources.FindObjectsOfTypeAll(typeof(Material))
	local textObj = Resources.FindObjectsOfTypeAll(typeof(Font))
	
	--Load material
	for i=0,obj.Length - 1 do
		if obj[i].name == "Font Material" then FontMat = obj[i] end
	end
	
	--Load font Japanese
	for i=0,textObj.Length - 1 do
		if textObj[i].name == "NotoSansJP-Bold" then
			FontJP = textObj[i]
			break
		end
	end

	return FontJP
end

util.InsertParentDir = function(dir)
	parentDir = dir
end

util.GetParentDir = function()
	return parentDir
end

util.InsertModules = function(module)
	modules = module
end

util.GetModulesDir = function()
	return modules
end

util.GetModules = function()
	local newModules = {}
	for _,v in pairs(util.GetModulesDir()) do
		table.insert(newModules, Path.GetFileNameWithoutExtension(v))
	end

	return newModules
end

util.InsertSettings = function(lip, dir)
	ini_parser = lip
	settingsDir = dir
	settings = ini_parser.load(settingsDir)
end

util.GetSettingsModule = function()
	return settings
end

util.GetSettings = function(module, key)
	if settings == nil or settings[module] == nil then return nil end
	return settings[module][key]
end

util.SetSettings = function(module, key, value)
	if settings == nil or settings[module] == nil then return end
	settings[module][key] = value
end

util.SaveSettings = function()
	if not ini_parser then return end
	ini_parser.save(settingsDir, settings)
end

util.ColorRGB = function(r, g, b)
	return Color(r / 255, g / 255, b / 255)
end

util.ColorRGBA = function(r, g, b, a)
	return Color(r / 255, g / 255, b / 255, a)
end

util.ColorHexToRGBA = function(hexValue, alpha)
	hexValue = hexValue:gsub("#","")
	local r = tonumber(hexValue:sub(1, 2), 16)
	local g = tonumber(hexValue:sub(3, 4), 16)
	local b = tonumber(hexValue:sub(5, 6), 16)
	return util.ColorRGBA(r, g, b, alpha)
end

util.LoadTexture = function(path)
	return UTIL:LoadTexture(path)
end

util.getAssetBundleFolderPath = function(platform)
	if (platform == 1) then
		return "bundles/Windows/"
	end
	if (platform == 2) then
		return "bundles/MacOS/"
	end
	if (platform == 3) then
		return "bundles/Android/"
	end
	if (platform == 4) then
		return "bundles/iOS/"
	end

	return "bundles/Other/"
end

util.GetPlatformPath = function()
	local platform = APPMAN:GetPlatformInt()
	if (platform == 1) then
		return "Windows/"
	end
	if (platform == 2) then
		return "MacOS/"
	end
	if (platform == 3) then
		return "Android/"
	end
	if (platform == 4) then
		return "iOS/"
	end

	return "Other/"
end

util.IsPlatformMobile = function()
	local platform = APPMAN:GetPlatformInt()
	return platform == 3 or platform == 4
end

util.LoadObjectHash = function(hash, item)
	return ASSETMAN:LoadGameObject(hash, item)
end

util.bump = function ()
	SCREENMAN:SystemMessage("Bump!")
end

return util
