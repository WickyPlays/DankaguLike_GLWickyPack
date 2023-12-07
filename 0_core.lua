--著者: Wicky
require "1_module.lua"
require "G_Difficulty.lua"
require "G_DamageTint.lua"
require "G_ArrowPath.lua"
require "G_TapEffect.lua"
require "G_JudgeViewer.lua"

--true = オン (on), false = オフ (off)
local mode_Difficulty = true
local mode_DamageTint = true
local mode_ArrowPath = true
local mode_TapEffect = true
local mode_JudgeViewer = true


local UnityEngine = CS.UnityEngine

function onloaded()
	local WickyCanvas = UnityEngine.GameObject("WickyCanvas")
	local WickyCanvasComp = WickyCanvas:AddComponent(typeof(UnityEngine.Canvas))
	local WickyCanvasScale = WickyCanvas:AddComponent(typeof(UnityEngine.UI.CanvasScaler))
	WickyCanvasComp.planeDistance = 1
	WickyCanvasComp.worldCamera = CAMERAMAN:GetCamera()
	WickyCanvasComp.renderMode = UnityEngine.RenderMode.ScreenSpaceOverlay
	WickyCanvasScale.uiScaleMode = UnityEngine.UI.CanvasScaler.ScaleMode.ScaleWithScreenSize
	WickyCanvasScale.referenceResolution = WGLVector2(1920, 1080)
	WickyCanvasScale.matchWidthOrHeight = 1
	WickyCanvasComp.enabled = false
	WickyCanvasComp.enabled = true

	if mode_Difficulty == true then
		Difficulty_onloaded(WickyCanvas)
	end

	if mode_DamageTint == true then
		DamageTint_onloaded(WickyCanvas)
	end

	if mode_ArrowPath == true then
		ArrowPath_onloaded(WickyCanvas)
	end

	if mode_TapEffect == true then
		TapEffect_onloaded()
	end

	if mode_JudgeViewer == true then
		JudgeViewer_onloaded(WickyCanvas)
	end
end

function update()
	if mode_DamageTint == true then
		DamageTint_update()
	end

	if mode_ArrowPath == true then
		ArrowPath_update()
	end

	if mode_TapEffect == true then
		TapEffect_update()
	end

	if mode_JudgeViewer == true then
		JudgeViewer_update()
	end
end

function onHitNote(id, lane, noteType, judgeType)
	if mode_DamageTint == true then
		DamageTint_onHitNote(id, lane, noteType, judgeType)
	end

	if mode_JudgeViewer == true then
		JudgeViewer_onHitNote(id, lane, noteType, judgeType)
	end
end

function onMissedNote(id, lane, noteType)
	if mode_DamageTint == true then
		DamageTint_onMissedNote(id, lane, noteType)
	end

	if mode_JudgeViewer == true then
		JudgeViewer_onMissedNote(id, lane, noteType)
	end
end

function ondestroy()
	if mode_DamageTint == true then
		DamageTint_ondestroy()
	end

	if mode_TapEffect == true then
		TapEffect_onDestroy()
	end

	if mode_JudgeViewer == true then
		JudgeViewer_onDestroy()
	end
end
