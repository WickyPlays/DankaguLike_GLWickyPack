--著者: Wicky

local execute = {}
execute.active = true

local MAX_ALPHA = 1
local UnityEngine = CS.UnityEngine
local GameObject = UnityEngine.GameObject
local _LaneEffectTex = nil

local _LaneEffectArr = {}
local _LaneAlpha = { 0, 0, 0, 0, 0, 0, 0 }
local _LaneColors = {}

execute.onloaded = function()
	local effectType = execute.GetOption("TYPE") or 1
	local maxAlpha = execute.GetOption("MAX_ALPHA") or 1
	local hexTapNote = execute.GetOption("TAP_NOTE_COLOR") or "#FFC500"
	local hexLongNote = execute.GetOption("LONG_NOTE_COLOR") or "#00D6FF"
	local hexFuzzyNote = execute.GetOption("FUZZY_NOTE_COLOR") or "#00FF20"

	_LaneColors[1] = hexTapNote
	_LaneColors[2] = hexLongNote
	_LaneColors[3] = hexFuzzyNote

	if maxAlpha then
		MAX_ALPHA = maxAlpha
	end

	if effectType == 2 then
		_LaneEffectTex = execute.LoadTexture("LaneEffect2.png")
	else
		_LaneEffectTex = execute.LoadTexture("LaneEffect1.png")
	end

	for i = 0, 6 do
		local lane = GameObject.Instantiate(LaneSpritePrefab)
		lane:SetColor(0, 0, 0, 0)
		lane:SetSortingLayer(1)
		lane:SetLanePosition(i)
		lane:GetSpriteRenderer().sprite = UTIL:CreateSprite(_LaneEffectTex)
		table.insert(_LaneEffectArr, lane)
	end
end

execute.onHitNote = function(id, lane, noteType, judgeType, isAttack)
	local colorIndex = 1
	if (noteType == 1) then
		colorIndex = 1
	elseif (noteType == 2 or noteType == 3 or noteType == 4) then
		colorIndex = 2
	elseif (noteType == 5 or noteType == 6 or noteType == 7 or noteType == 8) then
		colorIndex = 3
	end

	if lane >= 0 and lane <= 6 then
		local laneIndex = lane + 1
		_LaneAlpha[laneIndex] = MAX_ALPHA
		local color = _LaneColors[colorIndex]
		local colort = util.ColorHexToRGBA(color, 1)
		_LaneEffectArr[laneIndex]:SetColor(colort.r, colort.g, colort.b, _LaneAlpha[laneIndex])
	end
end

execute.update = function(e)

	-- Update lane effects (fade out)
	for i = 1, 7 do
		if _LaneAlpha[i] > 0 then
			_LaneAlpha[i] = _LaneAlpha[i] - 0.02
			if _LaneAlpha[i] < 0 then
				_LaneAlpha[i] = 0
			end

			-- Keep the same color but update alpha
			local color = _LaneEffectArr[i]:GetSpriteRenderer().color
			_LaneEffectArr[i]:SetColor(color.r, color.g, color.b, _LaneAlpha[i])
		end
	end
end

return execute
