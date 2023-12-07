--著者: Wicky

require "1_module.lua"

local FontJP = nil

--=================================
--		 MAIN SCRIPT
--=================================

function CreateLyricCanvas(WickyCanvas, name, pos, color, text, size)
	local TextCanvas = WGLGameObject(name)
	TextCanvas.gameObject.transform:SetParent(WickyCanvas.transform, false)
	TextCanvas:AddComponent(typeof(WGLUnityEngine.CanvasRenderer))
	_TextCanvasText = TextCanvas:AddComponent(typeof(WGLUnityEngine.UI.Text))
	TextCanvas.transform.anchorMin = WGLVector2(0, 0)
	TextCanvas.transform.anchorMax = WGLVector2(1, 1)
	TextCanvas.transform.localPosition = pos
	TextCanvas.transform.sizeDelta = WGLVector2(0, 0)
	_TextCanvasText.font = FontJP
	_TextCanvasText.fontSize = size
	_TextCanvasText.alignment = WGLUnityEngine.TextAnchor.UpperRight
	_TextCanvasText.text = text
	_TextCanvasText.color = color
end

function Difficulty_onloaded(WickyCanvas)
	
	local obj = WGLResources.FindObjectsOfTypeAll(typeof(WGLMaterial))
	local textObj = WGLResources.FindObjectsOfTypeAll(typeof(WGLUnityEngine.Font))
	
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

	local diffText = ''
	local diffColor = ColorRGB(255, 255, 255)
	local diffType = SONGMAN:GetDifficultyToInt()
	local diffMeter = SONGMAN:GetMeter()
    local diffX = false

	if diffType == 0 then 
		diffText = "Easy"
		diffColor = ColorRGB(0, 255, 32)
	elseif diffType == 1 then
		diffText = "Normal"
		diffColor = ColorRGB(0, 133, 255)
	elseif diffType == 2 then
		diffText = "Hard"
		diffColor = ColorRGB(255, 235, 0)
	elseif diffType == 3 then
		diffText = "Extra"
		diffColor = ColorRGB(255, 0, 34)
	elseif diffType == 4 then
		diffText = "Lunatic"
		diffColor = ColorRGB(222, 0, 255)
	end

    diffX = diffMeter == 12345678

    if (diffX) then
        CreateLyricCanvas(WickyCanvas, "TextDifficultyShadow", WGLVector3(-33, -1002, 0), diffColor, diffText .. ' X', 36) --36 = サイズ
        CreateLyricCanvas(WickyCanvas, "TextDifficulty", WGLVector3(-35, -1000, 0), ColorRGB(255, 255, 255), diffText .. ' X', 36) --36 = サイズ
    else 
        CreateLyricCanvas(WickyCanvas, "TextDifficultyShadow", WGLVector3(-33, -1002, 0), diffColor, diffText .. ' ' .. diffMeter, 36) --36 = サイズ
        CreateLyricCanvas(WickyCanvas, "TextDifficulty", WGLVector3(-35, -1000, 0), ColorRGB(255, 255, 255), diffText .. ' ' .. diffMeter, 36) --36 = サイズ
    
    end
end