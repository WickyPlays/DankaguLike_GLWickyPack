require "1_module.lua"

local FontMat = nil
local FontJP = nil

local judgeBr = 0
local judgeG = 0
local judgeF = 0
local judgeS = 0
local judgeB = 0
local judgeM = 0

local _JudgeBrText = nil
local _JudgeGText = nil
local _JudgeFText = nil
local _JudgeSText = nil
local _JudgeBText = nil
local _JudgeMText = nil

local SpriteBrillant = nil
local SpriteGreat = nil
local SpriteFast = nil
local SpriteSlow = nil
local SpriteBad = nil
local SpriteMiss = nil

function CreateJudgeCanvas(parentCanvas, name, pos, sprite)
	local JudgeImg = WGLGameObject(name)
	JudgeImg.gameObject.transform:SetParent(parentCanvas.transform, false)
	JudgeImg:AddComponent(typeof(WGLUnityEngine.CanvasRenderer))
	JudgeImgComp = JudgeImg:AddComponent(typeof(WGLUnityEngine.UI.Image))
	JudgeImgComp.sprite = sprite
	JudgeImgComp.transform.anchorMin = WGLVector2(0, 1)
	JudgeImgComp.transform.anchorMax = WGLVector2(0, 1)
	JudgeImgComp.transform.sizeDelta = WGLVector2(250, 60)
	JudgeImgComp.transform.anchoredPosition = pos

	local TextCanvas = WGLGameObject(name .. "Text")
	TextCanvas.gameObject.transform:SetParent(JudgeImg.transform, false)
	TextCanvas:AddComponent(typeof(WGLUnityEngine.CanvasRenderer))
	_TextCanvasText = TextCanvas:AddComponent(typeof(WGLUnityEngine.UI.Text))
	TextCanvas.transform.anchoredPosition = WGLVector2(200, -22)
	_TextCanvasText.font = FontJP
	_TextCanvasText.fontSize = 37
	_TextCanvasText.text = "0"

	return _TextCanvasText
end

function JudgeViewer_onloaded(WickyCanvas)
	local obj = CS.UnityEngine.Resources.FindObjectsOfTypeAll(typeof(WGLUnityEngine.Material))
	local textObj = CS.UnityEngine.Resources.FindObjectsOfTypeAll(typeof(WGLUnityEngine.Font))
	local spriteObj = CS.UnityEngine.Resources.FindObjectsOfTypeAll(typeof(WGLUnityEngine.Sprite))

	--Load material
	for i = 0, obj.Length - 1 do
		if obj[i].name == "Font Material" then FontMat = obj[i] end
	end

	--Load font Japanese
	for i = 0, textObj.Length - 1 do
		if textObj[i].name == "NotoSansJP-Bold" then
			FontJP = textObj[i]
			break
		end
	end

	for i = 0, spriteObj.Length - 1 do
		if spriteObj[i].name == "judge_0" then
			SpriteBrillant = spriteObj[i]
		elseif spriteObj[i].name == "judge_1" then
			SpriteGreat = spriteObj[i]
		elseif spriteObj[i].name == "judge_2" then
			SpriteFast = spriteObj[i]
		elseif spriteObj[i].name == "judge_3" then
			SpriteSlow = spriteObj[i]
		elseif spriteObj[i].name == "judge_4" then
			SpriteBad = spriteObj[i]
		elseif spriteObj[i].name == "judge_5" then
			SpriteMiss = spriteObj[i]
		end
	end

	local JudgementCanvas = WGLGameObject("JudgementCanvas")
	JudgementCanvas.gameObject.transform:SetParent(WickyCanvas.transform, false)
	JudgementCanvasComp = JudgementCanvas:AddComponent(typeof(WGLUnityEngine.Canvas))
	JudgementCanvasComp.renderMode = WGLUnityEngine.RenderMode.ScreenSpaceCamera
	JudgementCanvas.transform.anchorMin = WGLVector2(0, 1)
	JudgementCanvas.transform.anchorMax = WGLVector2(0, 1)
	JudgementCanvas.transform.pivot = WGLVector2(0, 1)

	_JudgeBrText = CreateJudgeCanvas(JudgementCanvas, "JudgeBr", WGLVector2(200, -280), SpriteBrillant)
	_JudgeGText = CreateJudgeCanvas(JudgementCanvas, "JudgeG", WGLVector2(200, -340), SpriteGreat)
	_JudgeFText = CreateJudgeCanvas(JudgementCanvas, "JudgeF", WGLVector2(200, -400), SpriteFast)
	_JudgeSText = CreateJudgeCanvas(JudgementCanvas, "JudgeS", WGLVector2(200, -460), SpriteSlow)
	_JudgeBText = CreateJudgeCanvas(JudgementCanvas, "JudgeB", WGLVector2(200, -520), SpriteBad)
	_JudgeMText = CreateJudgeCanvas(JudgementCanvas, "JudgeM", WGLVector2(200, -580), SpriteMiss)
end

function JudgeViewer_update()
	_JudgeBrText.text = judgeBr
	_JudgeGText.text = judgeG
	_JudgeFText.text = judgeF
	_JudgeSText.text = judgeS
	_JudgeBText.text = judgeB
	_JudgeMText.text = judgeM
end

function JudgeViewer_onHitNote(id, lane, noteType, judgeType)
	if judgeType == 0 then
		judgeBr = judgeBr + 1
	elseif judgeType == 1 then
		judgeG = judgeG + 1
	elseif judgeType == 2 then
		judgeF = judgeF + 1
	elseif judgeType == 3 then
		judgeS = judgeS + 1
	elseif judgeType == 4 then
		judgeB = judgeB + 1
	end
end

function JudgeViewer_onMissedNote(id, lane, noteType)
	judgeM = judgeM + 1
end

function JudgeViewer_onDestroy()
	judgeBr = 0
	judgeG = 0
	judgeF = 0
	judgeS = 0
	judgeB = 0
	judgeM = 0

	_JudgeBrText = nil
	_JudgeGText = nil
	_JudgeFText = nil
	_JudgeSText = nil
	_JudgeBText = nil
	_JudgeMText = nil

	SpriteBrillant = nil
	SpriteGreat = nil
	SpriteFast = nil
	SpriteSlow = nil
	SpriteBad = nil
	SpriteMiss = nil
end
