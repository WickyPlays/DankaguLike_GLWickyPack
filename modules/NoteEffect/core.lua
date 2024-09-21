--著者: Wicky

local execute = {}
execute.active = true

local ALPHA = nil
local MODE = nil
local NORMAL_NOTE, LONG_NOTE, FUZZY_NOTE, FUZZY_LONG_NOTE, LONG_NOTE_HOLD = nil, nil, nil, nil, nil

local UnityEngine = CS.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObject = UnityEngine.GameObject
local EffectPoolObj = nil

local _poolY, _poolG, _poolB, _poolGLong, _poolBLong = nil, nil, nil, nil, nil

--=============================
--         POOLING
--=============================

local function createEffect(prefab)
	return {
		prefab = prefab,
		active = false,
		ticks = 120,
		unlimited = false,
	}
end

local function createEffectPool(_prefab, maxEffects)
	local eff = {
		prefab = _prefab,
		maxEffects = maxEffects,
		effects = {}
	}

	eff.initializePool = function()
		if EffectPoolObj == nil then return end
		for i = 1, eff.maxEffects do
			local s = GameObject.Instantiate(eff.prefab)
			s.transform:SetParent(EffectPoolObj.transform, false)
			s.transform.localPosition = Vector3(0, 5000, 0)
			s.transform.localScale = Vector3(1.5, 1, 1)

			s:SetActive(false)
			table.insert(eff.effects, createEffect(s))
		end
	end

	eff.allEffectsActive = function()
		for _, effect in ipairs(eff.effects) do
			if not effect.active then
				return false
			end
		end
		return true
	end

	eff.retrieve = function(pos)
		if eff.allEffectsActive() then
			eff.initializePool()
		end
		for _, effect in ipairs(eff.effects) do
			if not effect.active then
				effect.prefab:SetActive(true)
				effect.active = true
				effect.ticks = 120

				effect.prefab.transform.localPosition = pos
				return effect
			end
		end
		return nil
	end

	eff.releaseEffect = function(effect)
		effect.active = false
		if (effect.prefab ~= nil) then
			effect.prefab:SetActive(false)
			effect.prefab.transform.localPosition = Vector3(0, 5000, 0)
		end
	end

	eff.getList = function()
		return eff.effects
	end

	eff.scan = function()
		for _, effect in ipairs(eff.effects) do
			if not effect.unlimited then
				if effect.active and effect.ticks > 0 then
					effect.ticks = effect.ticks - 1
					if effect.ticks <= 0 then
						eff.releaseEffect(effect)
					end
				end
			end
		end
	end

	eff.wipe = function()
		for _, effect in ipairs(eff.effects) do
			if effect.prefab ~= nil and effect.prefab.activeInHierarchy then
				effect.prefab:SetActive(false)
				GameObject.Destroy(effect.prefab)
			end
			effect.prefab = nil
			effect.active = false
			effect.ticks = 120
		end

		if (eff.prefab ~= nil) then
			eff.prefab = nil
		end

		eff.maxEffects = 0
		eff.effects = {}
	end

	return eff
end

--===============================

local function calculateValue(lane)
	if lane >= 0 and lane <= 6 then
		return -1.5 + lane * 0.5
	else
		return 0
	end
end

execute.onloaded = function()
	MODE = execute.GetOption("MODE")
	NORMAL_NOTE = execute.GetOption("NORMAL_NOTE")
	LONG_NOTE = execute.GetOption("LONG_NOTE")
	FUZZY_NOTE = execute.GetOption("FUZZY_NOTE")
	FUZZY_LONG_NOTE_HOLD = execute.GetOption("FUZZY_LONG_NOTE_HOLD")
	LONG_NOTE_HOLD = execute.GetOption("LONG_NOTE_HOLD")

	local hash = execute.LoadAssetBundle("G_NoteEffect/" .. MODE .. '/' .. util.GetPlatformPath() .. "hit")

	EffectPoolObj = GameObject("EffectPool")

	local _hitYellow = util.LoadObjectHash(hash, NORMAL_NOTE)
	local _hitGreen = util.LoadObjectHash(hash, FUZZY_NOTE)
	local _hitBlue = util.LoadObjectHash(hash, LONG_NOTE)
	local _hitGreenLong = util.LoadObjectHash(hash, FUZZY_LONG_NOTE_HOLD)
	local _hitBlueLong = util.LoadObjectHash(hash, LONG_NOTE_HOLD)

	_poolY = createEffectPool(_hitYellow, 2)
	_poolY.initializePool()
	_poolG = createEffectPool(_hitGreen, 2)
	_poolG.initializePool()
	_poolB = createEffectPool(_hitBlue, 2)
	_poolB.initializePool()

	_poolGLong = createEffectPool(_hitGreenLong, 2)
	_poolGLong.initializePool()

	_poolBLong = createEffectPool(_hitBlueLong, 2)
	_poolBLong.initializePool()

	GAMESTATE:ChangeJudgeEffect(0)
end

execute.onHitNote = function(id, lane, noteType, judgeType, isAttack)
	if (noteType == 1) then
		_poolY.retrieve(Vector3(calculateValue(lane), 0, 0))
	elseif (noteType == 2 or noteType == 3 or noteType == 4) then
		_poolB.retrieve(Vector3(calculateValue(lane), 0, 0))
	elseif (noteType == 5 or noteType == 6 or noteType == 7 or noteType == 8) then
		_poolG.retrieve(Vector3(calculateValue(lane), 0, 0))
	end
end

local longHandler = {}
local longIndex = 0

local function removeLongHandler(index)
	for i = 1, #longHandler do
		if longHandler[i].index == index then
			table.remove(longHandler, i)
			return
		end
	end
end

execute.onSpawnLong = function(longController)
	local noteEffectObj = nil
	local type = longController.LongType

	if type == CS.LongType.Long then
		noteEffectObj = _poolBLong.retrieve(Vector3(-100, 0, 0))
	elseif type == CS.LongType.FuzzyLong then
		noteEffectObj = _poolGLong.retrieve(Vector3(-100, 0, 0))
	else
		return
	end

	noteEffectObj.unlimited = true
	local newLongHandler = {
		index = longIndex,
		active = false,
		longController = longController,
		noteEffect = noteEffectObj
	}

	table.insert(longHandler, newLongHandler)
	longIndex = longIndex + 1
end

execute.update = function(e)
	if _poolY then
		_poolY.scan()
	end

	if _poolG then
		_poolG.scan()
	end

	if _poolB then
		_poolB.scan()
	end

	if _poolGLong and _poolBLong then
		_poolGLong.scan()
		_poolBLong.scan()

		for _, longNote in ipairs(longHandler) do
			if not longNote.active and not longNote.longController.IsReleased then
				if longNote.longController.CurrentPosX >= -2 and longNote.longController.CurrentPosX <= 2 then
					longNote.active = true
				end
			else
				longNote.noteEffect.prefab.transform.localPosition = Vector3(longNote.longController.CurrentPosX, 0, 0)

				if longNote.longController.IsReleased then
					longNote.active = false

					local type = longNote.longController.LongType

					if type == CS.LongType.Long then
						_poolBLong.releaseEffect(longNote.noteEffect)
						removeLongHandler(longNote.index)
					elseif type == CS.LongType.FuzzyLong then
						_poolGLong.releaseEffect(longNote.noteEffect)
						removeLongHandler(longNote.index)
					end
				end
			end
		end
	end
end

return execute