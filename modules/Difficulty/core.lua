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

local function CreateLyricCanvas(WickyCanvas, name, pos, color, text, size)
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
	_TextCanvasText.alignment = UnityEngine.TextAnchor.LowerRight
	_TextCanvasText.text = text
	_TextCanvasText.color = color
end

execute.onloaded = function()
	
	local WickyCanvas = util.GetCanvas()

	local diffText = ''
	local diffColor = util.ColorRGB(0, 0, 0)
	local diffType = SONGMAN:GetDifficultyToInt()
	local diffMeter = SONGMAN:GetMeter()
    local diffX = false
	local size = execute.GetOption("size")

	if diffType == 0 then
		diffText = "Easy"
		diffColor = util.ColorRGB(0, 255, 32)
	elseif diffType == 1 then
		diffText = "Normal"
		diffColor = util.ColorRGB(0, 133, 255)
	elseif diffType == 2 then
		diffText = "Hard"
		diffColor = util.ColorRGB(255, 235, 0)
	elseif diffType == 3 then
		diffText = "Extra"
		diffColor = util.ColorRGB(255, 0, 34)
	elseif diffType == 4 then
		diffText = "Lunatic"
		diffColor = util.ColorRGB(222, 0, 255)
	end

    diffX = diffMeter == 12345678

    if (diffX) then
        CreateLyricCanvas(WickyCanvas, "TextDifficultyShadow", Vector3(-15, 20, 0), diffColor, diffText .. ' X', size)
        CreateLyricCanvas(WickyCanvas, "TextDifficulty", Vector3(-17, 22, 0), util.ColorRGB(255, 255, 255), diffText .. ' X', size)
    else
        CreateLyricCanvas(WickyCanvas, "TextDifficultyShadow", Vector3(-15, 20, 0), diffColor, diffText .. ' ' .. diffMeter, size)
        CreateLyricCanvas(WickyCanvas, "TextDifficulty", Vector3(-17, 22, 0), util.ColorRGB(255, 255, 255), diffText .. ' ' .. diffMeter, size)
    
    end
end

return execute