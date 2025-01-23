local execute = {}
execute.active = true

local UnityEngine = CS.UnityEngine
local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time

local Camera = nil
local targetTilt = 0
local currentTilt = 0
local smoothSpeed = 6
local inactivityTimer = 0
local inactivityThreshold = 0.01

local activeAngles = {} -- Table to store active angles for multiple inputs

local function Lerp(a, b, t)
  return a + (b - a) * t
end

local function MapPosXToLane(posX)
  if posX <= -2 or posX >= 2 then
    return 3
  end
  return math.floor((posX + 1.75) * 2)
end

local function CalculateMidAngle()
  local sum = 0
  local count = 0
  for _, angle in pairs(activeAngles) do
    sum = sum + angle
    count = count + 1
  end
  if count > 0 then
    return sum / count
  else
    return 0
  end
end

execute.onloaded = function()
  Camera = GameObject.Find("Main Camera")
end

execute.update = function()
  if not Camera then return end

  currentTilt = Lerp(currentTilt, targetTilt, smoothSpeed * Time.deltaTime)
  Camera.transform.eulerAngles = Vector3(30, 0, currentTilt)

  if targetTilt == 0 then
    inactivityTimer = inactivityTimer + Time.deltaTime
  else
    inactivityTimer = 0
  end

  -- Automatically return to tilt 0 after inactivity threshold
  if inactivityTimer >= inactivityThreshold then
    targetTilt = 0
  end
end

execute.onInputDown = function(touchId, posX, screenPosX, screenPosY)
  if not Camera then return end

  local angles = {-3, -2, -1, 0, 1, 2, 3}
  local lane = MapPosXToLane(posX)

  if lane >= 0 and lane <= 6 then
    activeAngles[touchId] = angles[lane + 1] -- Store the angle for this input
    targetTilt = CalculateMidAngle() -- Recalculate the mid angle
  end
end

execute.onInputMove = function(touchId, posX, screenPosX, screenPosY)
  if not Camera then return end

  local angles = {-3, -2, -1, 0, 1, 2, 3}
  local lane = MapPosXToLane(posX)

  if lane >= 0 and lane <= 6 then
    activeAngles[touchId] = angles[lane + 1] -- Update the angle for this input
    targetTilt = CalculateMidAngle() -- Recalculate the mid angle
  end
end

execute.onInputUp = function(touchId, posX, screenPosX, screenPosY)
  if not Camera then return end

  activeAngles[touchId] = nil -- Remove the angle for this input
  targetTilt = CalculateMidAngle() -- Recalculate the mid angle
end

return execute
