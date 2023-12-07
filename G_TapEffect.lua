require "1_module.lua"

local SIZE = 2.2 --サイズ

local held = false
local width = SCREENMAN:GetScreenWidth()
local height = SCREENMAN:GetScreenHeight()
local _particlePool = nil
local _platform = -1
local _ring = nil
local WickyCanvasTE = nil

--=================================
--		 POOLING MODULE
--=================================

local Particle = {}
local ParticlePool = {}

local function setupPool()
	Particle.__index = Particle

	function Particle.new(prefab)
		local self = setmetatable({}, Particle)
		self.prefab = prefab
		self.active = false
		self.ticks = 0
		return self
	end

	ParticlePool.__index = ParticlePool

	function ParticlePool.new(maxParticles)
		local self = setmetatable({}, ParticlePool)
		self.maxParticles = maxParticles
		self.particles = {}
		self:initializePool()
		return self
	end

	function ParticlePool:initializePool()
		for i = 1, self.maxParticles do
			local ParticleProp = WGLGameObject("ParticleProp")
			ParticleProp.transform:SetParent(WickyCanvasTE.transform, false)
			local s = WGLGameObject.Instantiate(_ring)
			s.transform:SetParent(ParticleProp.transform, false)
			s.transform.localPosition = WGLVector3(0, 0, 0)
			ParticleProp.transform.localPosition = WGLVector3(1000, 0, 0)
			ParticleProp:SetActive(false)
			table.insert(self.particles, Particle.new(ParticleProp))
		end
	end

	function ParticlePool:getParticle()
		if self:allParticlesActive() then
			self:initializePool()
		end
		for _, particle in ipairs(self.particles) do
			if not particle.active then
				particle.active = true
				particle.ticks = 25
				return particle
			end
		end
		return nil
	end

	function ParticlePool:allParticlesActive()
		for _, particle in ipairs(self.particles) do
			if not particle.active then
				return false
			end
		end
		return true
	end

	function ParticlePool:Scan()
		for _, particle in ipairs(self.particles) do
			if particle.active and particle.ticks > 0 then
				particle.ticks = particle.ticks - 0.1
				if particle.ticks <= 0 then
					self:releaseParticle(particle)
				end
			end
		end
	end

	function ParticlePool:releaseParticle(particle)
		particle.active = false
		particle.ticks = 0
		particle.prefab:SetActive(false)
	end

	function ParticlePool:Wipe()
		for _, particle in ipairs(self.particles) do
			if particle.prefab ~= nil then
				WGLGameObject.Destroy(particle.prefab)
			end
		end
	end
end

--=================================
--		 MAIN SCRIPT
--=================================

function TapEffect_onloaded()
	_platform = APPMAN:GetPlatformInt()
	local hash = ASSETMAN:LoadAssetBundle(getAssetBundleFolderPath(_platform) .. "ring")
	_ring = ASSETMAN:LoadGameObject(hash, "Sparkle")

	WickyCanvasTE = WGLGameObject("WickyCanvasTapEffect")
	local WickyCanvasTEComp = WickyCanvasTE:AddComponent(typeof(WGLUnityEngine.Canvas))
	local WickyCanvasTEScale = WickyCanvasTE:AddComponent(typeof(WGLUnityEngine.UI.CanvasScaler))
	WickyCanvasTEComp.planeDistance = SIZE
	WickyCanvasTEComp.worldCamera = CAMERAMAN:GetCamera()
	WickyCanvasTEComp.renderMode = WGLUnityEngine.RenderMode.ScreenSpaceCamera
	WickyCanvasTEScale.uiScaleMode = WGLUnityEngine.UI.CanvasScaler.ScaleMode.ScaleWithScreenSize
	WickyCanvasTEScale.referenceResolution = WGLVector2(width, height)
	WickyCanvasTEScale.matchWidthOrHeight = 1
	--Refresh
	WickyCanvasTEComp.enabled = false
	WickyCanvasTEComp.enabled = true

	--Pooling
	setupPool()
	_particlePool = ParticlePool.new(20)
end

function TapEffect_update()
	_particlePool:Scan()

	if _platform == 1 or _platform == 2 then
		local pressed = WGLInput.GetMouseButton(0)
		if pressed then
			if held == false then
				held = true
				local touchPosition = WGLInput.mousePosition
				local myParticle = _particlePool:getParticle()
				if myParticle == nil then return end
				myParticle.prefab:SetActive(true)
				myParticle.prefab.transform.localPosition = WGLVector3(touchPosition.x - (width / 2),
					touchPosition.y - (height / 2), 0)
			end
		else
			held = false
		end
	elseif _platform == 3 or _platform == 4 then
		if WGLInput.touchCount <= 0 then return end
		for i = 0, WGLInput.touchCount - 1 do
			local pressed = WGLInput.GetTouch(i)
			local touchPhase = pressed.phase
			if touchPhase == WGLUnityEngine.TouchPhase.Began then
				local touchPosition = pressed.position
				local myParticle = _particlePool:getParticle()
				if myParticle == nil then return end
				myParticle.prefab:SetActive(true)
				myParticle.prefab.transform.localPosition = WGLVector3(touchPosition.x - (width / 2),
					touchPosition.y - (height / 2), 0)
			end
		end
	end
end

function TapEffect_onDestroy()
	_particlePool:Wipe()
	table.remove(ParticlePool)
	table.remove(Particle)
	WGLGameObject.Destroy(_ring)
	WGLGameObject.Destroy(WickyCanvasTE)
end
