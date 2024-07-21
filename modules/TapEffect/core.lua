local UnityEngine = CS.UnityEngine
local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Input = UnityEngine.Input

local WickyCanvasTE = nil
local held = false
local _particlePool = nil
local _platform = -1
local _ring = nil
local width = util.GetScreenWidth()
local height = util.GetScreenHeight()

--=================================
--		 POOLING MODULE
--=================================

local execute = {}
execute.active = true

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
		WickyCanvasTE = util.CreateCanvas("WickyCanvasTE", 3)
		for i = 1, self.maxParticles do
			local ParticleProp = GameObject("ParticleProp")
			ParticleProp.transform:SetParent(WickyCanvasTE.transform, false)
			local s = GameObject.Instantiate(_ring)
			s.transform:SetParent(ParticleProp.transform, false)
			s.transform.localPosition = Vector3(0, 0, 0)
			ParticleProp.transform.localPosition = Vector3(1000, 0, 0)
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
				GameObject.Destroy(particle.prefab)
			end
		end
	end
end

--=================================
--		 MAIN SCRIPT
--=================================

execute.onloaded = function()
	_platform = APPMAN:GetPlatformInt()
	local hash = execute.LoadAssetBundle("bundles\\" .. util.GetPlatformPath() .. "ring")
	_ring = util.LoadObjectHash(hash, "Sparkle")

	--Pooling
	setupPool()
	_particlePool = ParticlePool.new(20)
end

execute.start = function()
	if WickyCanvasTE == nil then return end
	WickyCanvasTEComp = WickyCanvasTE:GetComponent(typeof(UnityEngine.Canvas))
	WickyCanvasTEComp.scaleFactor = 1
end

execute.update = function()
	if WickyCanvasTE == nil or _particlePool == nil then return end

	_particlePool:Scan()

	if _platform == 1 or _platform == 2 then
		local pressed = Input.GetMouseButton(0)
		if pressed then
			if held == false then
				held = true
				local touchPosition = Input.mousePosition
				local myParticle = _particlePool:getParticle()
				if myParticle == nil then return end
				myParticle.prefab:SetActive(true)
				myParticle.prefab.transform.localPosition = Vector3(touchPosition.x - (width / 2),
					touchPosition.y - (height / 2), 0)
			end
		else
			held = false
		end
	elseif _platform == 3 or _platform == 4 then
		if Input.touchCount <= 0 then return end
		for i = 0, Input.touchCount - 1 do
			local pressed = Input.GetTouch(i)
			local touchPhase = pressed.phase
			if touchPhase == UnityEngine.TouchPhase.Began then
				local touchPosition = pressed.position
				local myParticle = _particlePool:getParticle()
				if myParticle == nil then return end
				myParticle.prefab:SetActive(true)
				myParticle.prefab.transform.localPosition = Vector3(touchPosition.x - (width / 2),
					touchPosition.y - (height / 2), 0)
			end
		end
	end
end

execute.ondestroy = function()
	_particlePool:Wipe()
	table.remove(ParticlePool)
	table.remove(Particle)
	GameObject.Destroy(_ring)
	GameObject.Destroy(WickyCanvasTE)
end

return execute