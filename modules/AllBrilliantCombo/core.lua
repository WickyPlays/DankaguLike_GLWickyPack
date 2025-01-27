--著者: Wicky

local execute = {}
execute.active = true

local UnityEngine = CS.UnityEngine
local GameObject = UnityEngine.GameObject
local Color = UnityEngine.Color
local Mathf = UnityEngine.Mathf

local isAllBrillant = true
local ComboTextTMP = nil
local ComboLabelTMP = nil
local time = 0
local animationSpeed = 3

execute.onloaded = function()
  local ComboText = GameObject.Find("CameraCanvas/ComboView/Panel/ComboText (TMP)")
  ComboTextTMP = ComboText:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))
  -- ComboLabelTMP = ComboLabel:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))

  animationSpeed = execute.GetOption("speed")
end

execute.update = function()

  if ComboTextTMP == nil then return end

  if not isAllBrillant then
    local gradient = CS.TMPro.VertexGradient()
    gradient.topLeft = util.ColorRGBA(67, 43, 13, 255)
    gradient.topRight = util.ColorRGBA(67, 43, 13, 255)
    gradient.bottomLeft = util.ColorRGBA(173, 134, 0, 255)
    gradient.bottomRight = util.ColorRGBA(173, 134, 0, 255)

    ComboTextTMP.colorGradient = gradient
    return
  end

  time = time + UnityEngine.Time.deltaTime * animationSpeed

  local colors = {
    util.ColorRGBA(245, 0, 0, 255), -- Red
    util.ColorRGBA(255, 173, 0, 255), -- Yellow
    util.ColorRGBA(17, 145, 0, 255), -- Green
    util.ColorRGBA(0, 171, 255, 255), -- Blue
    util.ColorRGBA(139, 0, 255, 255) -- Purple
  }

  -- Number of colors in the cycle
  local colorCount = #colors

  local gradient = CS.TMPro.VertexGradient()
  for i = 0, 1 do
    local t = (time + i * 0.5) % colorCount
    local index1 = Mathf.FloorToInt(t) + 1
    local index2 = (index1 % colorCount) + 1
    local factor = t % 1

    -- Interpolate between two colors
    local interpolatedColor = Color.Lerp(colors[index1], colors[index2], factor)

    if i == 0 then
      gradient.topLeft = interpolatedColor
      gradient.topRight = interpolatedColor
    else
      gradient.bottomLeft = interpolatedColor
      gradient.bottomRight = interpolatedColor
    end
  end

  ComboTextTMP.colorGradient = gradient
  -- ComboLabelTMP.colorGradient = gradient
end

execute.onHitNote = function(id, lane, noteType, judgeType, isAttack)
  if judgeType > 0 then
    isAllBrillant = false
  end
end

execute.onMissedNote = function(id, lane, noteType)
  isAllBrillant = false
end

return execute
