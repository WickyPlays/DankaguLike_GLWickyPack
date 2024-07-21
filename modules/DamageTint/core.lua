--著者: Wicky

-- require "tools/module.lua"

local execute = {}
execute.active = true

local UnityEngine = CS.UnityEngine
local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local Time = UnityEngine.Time

local Texture = nil
local DamageTint = nil
local colorTween1 = nil
local DamageColor = nil

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
    self.targetDanceColor = util.ColorRGBA(0, 0, 0, 0)
    self.tweenDuration = duration
	return self
end

function SpriteColorTween:Update()
    if self.elapsedTime < self.tweenDuration then
        self.elapsedTime = self.elapsedTime + Time.deltaTime
        local currentDanceColor = Color.Lerp(self.initialColor, self.targetDanceColor, self.elapsedTime / self.tweenDuration)
		self.danceTexture.color = currentDanceColor
    else
		self.danceTexture.color = self.targetDanceColor
    end
end

--=================================
--		 MAIN SCRIPT
--=================================

execute.onloaded = function()

	DamageColor =  util.ColorHexToRGBA(execute.GetOption("color"), tonumber(execute.GetOption("alpha")))

	local WickyCanvas = util.GetCanvas()
	Texture = execute.LoadTexture("G_DamageTint.png")
	--Create light (left side) (WickyCanvas)

	local Dance1Obj = GameObject("DamageTint")
	Dance1Obj.gameObject.transform:SetParent(WickyCanvas.transform, false)
	DamageTint = Dance1Obj:AddComponent(typeof(UnityEngine.UI.RawImage))
	DamageTint.texture = Texture
	DamageTint.transform.anchorMin = Vector2(0, 0)
	DamageTint.transform.anchorMax = Vector2(1, 1)
	DamageTint.transform.sizeDelta = Vector2(0, 0)
	DamageTint.color = util.ColorRGBA(0, 0, 0, 0)

end

execute.update = function()
	if colorTween1 ~= nil then
		colorTween1:Update()
	end
end


execute.onHitNote = function(id, lane, noteType, judgeType, isAttack)
	if (judgeType == 4) then
		colorTween1 = SpriteColorTween.new(DamageTint, DamageColor, .4)
	end
end

execute.onMissedNote = function(id, lane, noteType)
 	colorTween1 = SpriteColorTween.new(DamageTint, DamageColor, .4)
end

execute.ondestroy = function()
	Texture = nil
	DamageTint = nil
	colorTween1 = nil
end

return execute