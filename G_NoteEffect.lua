--Set this for beam alpha (DO NOT SET HIGH NUMBER)
--ビームアルファにこれを設定してください（高い数値を設定しないでください）

local ALPHA = 0.6 --アルファ
local MODE = "Beam01"

--Supports: Red, Yellow, Orange, Green, Lime, Blue, Dark Blue, Purple, Pink, White
local NORMAL_NOTE = "HitLightPurple"
local LONG_NOTE = "HitLightBlue"
local FUZZY_NOTE = "HitLightGreen"

local _platform = nil
local Vector3 = CS.UnityEngine.Vector3
local GameObject = CS.UnityEngine.GameObject
local Color = CS.UnityEngine.Color
local EffectPoolObj = nil

local _poolY, _poolG, _poolB

--=============================
--         POOLING
--=============================

local function createEffect(prefab)
	return {
		prefab = prefab,
		active = false,
		ticks = 120
	}
end

local function createEffectPool(_prefab, maxEffects)

	local eff = {
		prefab = _prefab,
		maxEffects = maxEffects,
		effects = {}
	}

	eff.initializePool = function()
		for i = 1, eff.maxEffects do
			local s = GameObject.Instantiate(eff.prefab)
			s.transform:SetParent(EffectPoolObj.transform, false)
			s.transform.localPosition = Vector3(0, 5000, 0)
			local particleRenderer = s:GetComponent(typeof(CS.UnityEngine.ParticleSystemRenderer))
			particleRenderer.material.color = Color(255, 255, 255, ALPHA / 100)

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

	eff.retrieve = function (pos)
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
			if effect.active and effect.ticks > 0 then
				effect.ticks = effect.ticks - 1
				if effect.ticks <= 0 then
					eff.releaseEffect(effect)
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

local function getAssetBundleFolderPath(platform)
	if (platform == 1) then
		return "shaders/Windows/"
	end
	if (platform == 2) then
		return "shaders/MacOS/"
	end
	if (platform == 3) then
		return "shaders/Android/"
	end
	if (platform == 4) then
		return "shaders/iOS/"
	end

	return "shaders/Other/"
end

local function calculateValue(lane)
	if lane >= 0 and lane <= 6 then
		return -1.5 + lane * 0.5
	else
		return 0
	end
end

function NoteEffect_onloaded()
	_platform = APPMAN:GetPlatformInt()
	local hash = ASSETMAN:LoadAssetBundle("G_NoteEffect/" .. MODE .. '/' .. getAssetBundleFolderPath(_platform) .. "hit")

	EffectPoolObj = GameObject("EffectPool")

	local _hitYellow = ASSETMAN:LoadGameObject(hash, NORMAL_NOTE)
	local _hitGreen = ASSETMAN:LoadGameObject(hash, FUZZY_NOTE)
	local _hitBlue = ASSETMAN:LoadGameObject(hash, LONG_NOTE)

	_poolY = createEffectPool(_hitYellow, 2)
	_poolY.initializePool()
	_poolG = createEffectPool(_hitGreen, 2)
	_poolG.initializePool()
	_poolB = createEffectPool(_hitBlue, 2)
	_poolB.initializePool()

	GAMESTATE:ChangeJudgeEffect(0)
end

function NoteEffect_onHitNote(id, lane, noteType, judgeType)
	if (noteType == 1) then
		_poolY.retrieve(Vector3(calculateValue(lane), 0, 0))
	elseif (noteType == 2 or noteType == 3 or noteType == 4) then
		_poolB.retrieve(Vector3(calculateValue(lane), 0, 0))
	elseif (noteType == 5 or noteType == 6 or noteType == 7 or noteType == 8) then
		_poolG.retrieve(Vector3(calculateValue(lane), 0, 0))
	end
end

function NoteEffect_update()
	if _poolY then
		_poolY.scan()
	end

	if _poolG then
		_poolG.scan()
	end

	if _poolB then
		_poolB.scan()
	end
end