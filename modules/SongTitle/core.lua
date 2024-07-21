--著者: Wicky

local _TextCanvasText = nil
local UnityEngine = CS.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local GameObject = UnityEngine.GameObject

local execute = {}
execute.active = true

--=================================
--		 MAIN SCRIPT
--=================================

local function CreateCanvas(WickyCanvas, name, pos, color, text, size)
	local TextCanvas = GameObject(name)
	TextCanvas.gameObject.transform:SetParent(WickyCanvas.transform, false)
	TextCanvas:AddComponent(typeof(UnityEngine.CanvasRenderer))
	_TextCanvasText = TextCanvas:AddComponent(typeof(UnityEngine.UI.Text))
	TextCanvas.transform.anchorMin = Vector2(0, 0)
	TextCanvas.transform.anchorMax = Vector2(1, 1)
	TextCanvas.transform.localPosition = pos
	TextCanvas.transform.sizeDelta = Vector2(0, 0)
	_TextCanvasText.font = util.GetFontJP()
	_TextCanvasText.fontSize = size
	_TextCanvasText.alignment = UnityEngine.TextAnchor.UpperLeft
	_TextCanvasText.text = text
	_TextCanvasText.color = color
end

execute.onloaded = function()
	local WickyCanvas = util.GetCanvas()

	local diffText = SONGMAN:GetTitle()
	local diffColor = util.ColorRGB(0, 0, 0)
	local diffType = SONGMAN:GetDifficultyToInt()

	if diffType == 0 then
		diffColor = util.ColorRGB(0, 255, 32)
	elseif diffType == 1 then
		diffColor = util.ColorRGB(0, 133, 255)
	elseif diffType == 2 then
		diffColor = util.ColorRGB(255, 235, 0)
	elseif diffType == 3 then
		diffColor = util.ColorRGB(255, 0, 34)
	elseif diffType == 4 then
		diffColor = util.ColorRGB(222, 0, 255)
	end

	CreateCanvas(WickyCanvas, "SongTitleShadow", Vector3(33, -1002, 0), diffColor,
		diffText, execute.GetOption("size"))
	CreateCanvas(WickyCanvas, "SongTitle", Vector3(35, -1000, 0), util.ColorRGB(255, 255, 255),
		diffText,  execute.GetOption("size"))
end

return execute
