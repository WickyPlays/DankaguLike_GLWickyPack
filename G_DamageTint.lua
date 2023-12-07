--著者: Wicky

require "1_module.lua"

local Texture = nil
local DamageTint = nil
local colorTween1 = nil

--=================================
--			MODULE
--=================================

local SpriteColorTween = {}
SpriteColorTween.__index = SpriteColorTween

function SpriteColorTween.new(danceTexture, fromColor, duration)
	local self = setmetatable({}, SpriteColorTween)
	self.danceTexture = danceTexture
    self.initialColor = fromColor
    self.elapsedTime = 0
    self.targetDanceColor = ColorRGBA(0, 0, 0, 0)
    self.tweenDuration = duration
	return self
end

function SpriteColorTween:Update()
    if self.elapsedTime < self.tweenDuration then
        self.elapsedTime = self.elapsedTime + WGLTime.deltaTime
        local currentDanceColor = WGLColor.Lerp(self.initialColor, self.targetDanceColor, self.elapsedTime / self.tweenDuration)
		self.danceTexture.color = currentDanceColor
    else
		self.danceTexture.color = self.targetDanceColor
    end
end


--=================================
--		 MAIN SCRIPT
--=================================

function DamageTint_onloaded(WickyCanvas)

	Texture = UTIL:LoadTexture("G_DamageTint.png")
	--Create light (left side) (WickyCanvas)
	local Dance1Obj = WGLGameObject("DamageTint")
	Dance1Obj.gameObject.transform:SetParent(WickyCanvas.transform, false)
	DamageTint = Dance1Obj:AddComponent(typeof(WGLUnityEngine.UI.RawImage))
	DamageTint.texture = Texture
	DamageTint.transform.anchorMin = WGLVector2(0, 0)
	DamageTint.transform.anchorMax = WGLVector2(1, 1)
	DamageTint.transform.sizeDelta = WGLVector2(0, 0)
	DamageTint.color = ColorRGBA(0, 0, 0, 0)

end

function DamageTint_update()
	if colorTween1 ~= nil then
		colorTween1:Update()
	end
end


function DamageTint_onHitNote(id, lane, noteType, judgeType)
	if (judgeType == 4) then
		colorTween1 = SpriteColorTween.new(DamageTint, ColorRGBA(255, 0, 86, 1), .4)
	end
end

function DamageTint_onMissedNote(id, lane, noteType)
 	colorTween1 = SpriteColorTween.new(DamageTint, ColorRGBA(255, 0, 86, 1), .4)
end

function DamageTint_ondestroy()
	Texture = nil
	DamageTint = nil
	colorTween1 = nil
end