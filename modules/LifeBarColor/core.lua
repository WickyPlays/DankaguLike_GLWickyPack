local execute = {}
execute.active = true

local UnityEngine = CS.UnityEngine
local GameObject = UnityEngine.GameObject
local Image = UnityEngine.UI.Image
local Color = UnityEngine.Color

local LifeFill = nil
local LifeImage = nil
local LifeBg = nil
local LifeBgImage = nil

execute.onloaded = function()
  LifeBg = GameObject.Find("CameraCanvas/LifeView/LifeSlider/Background")
  LifeFill = GameObject.Find("CameraCanvas/LifeView/LifeSlider/Fill Area/Fill")
  LifeImage = LifeFill:GetComponent(typeof(Image))
  LifeBgImage = LifeBg:GetComponent(typeof(Image))
end

local function lerp(a, b, t)
  return a + (b - a) * t
end

local function getLifeColor(life)
  local red, green, blue = 0, 0, 0

  if life <= 0.5 then
    red = 1
    green = lerp(0, 1, life * 2)
  elseif life <= 0.7 then
    red = 1
    green = 1
  else
    red = lerp(1, 0, (life - 0.7) * 5)
    green = 1
  end

  return Color(red, green, blue, 1)
end

execute.update = function()
  local life = PLAYERSTATS:GetCurrentLife()

  if LifeImage then
    LifeImage.color = getLifeColor(life)
  end

  --Is this necessary?
  if LifeBgImage then
    LifeBgImage.color = getLifeColor(life)
  end
end

return execute
