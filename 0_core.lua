--著者: Wicky
require "1_module.lua"
require "G_Difficulty.lua"
require "G_DamageTint.lua"
require "G_ArrowPath.lua"
require "G_TapEffect.lua"
require "G_JudgeViewer.lua"
require "G_NoteEffect.lua"

--true = オン (on), false = オフ (off)
local mode_Difficulty = true
local mode_DamageTint = false
local mode_ArrowPath = false
local mode_TapEffect = false
local mode_JudgeViewer = false
local mode_NoteEffect = true


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

	if mode_NoteEffect == true then
		NoteEffect_onloaded()
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

	if mode_NoteEffect == true then
		NoteEffect_update()
	end
end

function onHitNote(id, lane, noteType, judgeType)
	if mode_DamageTint == true then
		DamageTint_onHitNote(id, lane, noteType, judgeType)
	end

	if mode_JudgeViewer == true then
		JudgeViewer_onHitNote(id, lane, noteType, judgeType)
	end

	if mode_NoteEffect == true then
		NoteEffect_onHitNote(id, lane, noteType, judgeType)
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
