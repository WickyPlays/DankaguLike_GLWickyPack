local execute = {}
execute.active = true

local Directory = CS.System.IO.Directory
local Vector3 = CS.UnityEngine.Vector3
local Vector2 = CS.UnityEngine.Vector2
local Color = CS.UnityEngine.Color
local Time = CS.UnityEngine.Time
local GameObject = CS.UnityEngine.GameObject

local MusicTimePanel = nil
local TintBar = nil
local colorTween1 = nil
local damageTween = nil
local _sprite = nil
local spriteChar = nil
local FlameContainer = nil

-- Resources
local _BossDmgEffectPrefab = nil
local ClonedBossBarFill = nil
local _BossBarMarker = nil

-- Numberic values
local BossBarDivision = 0.01
local BossBarMarkerDivision = 1

local SpriteColorTween = {}
SpriteColorTween.__index = SpriteColorTween

--Check if the chart has any attack notes
local function HasAttackNotes()
    local notes = GAMESTATE:GetNotes()
    for i = 0, notes.Length - 1 do
        if notes[i].IsAttack then
            return true
        end
    end
    return false
end

--Grab first img file with [BOSS] on it
local function findFirstBossFile()
    local files = Directory.GetFiles(SONGMAN:GetSongDir(), "*[BOSS]*")
    if files == nil or files.Length == 0 then return nil end
    return files[0]
end

local function ColorRGBA(r, g, b, a)
    return Color(r / 255, g / 255, b / 255, a)
end

function SpriteColorTween.new(danceTexture, fromColor, toColor, duration)
    local self = setmetatable({}, SpriteColorTween)
    self.danceTexture = danceTexture
    self.initialColor = fromColor
    self.elapsedTime = 0
    self.targetDanceColor = toColor
    self.tweenDuration = duration
    return self
end

function SpriteColorTween:Update()
    if self.elapsedTime < self.tweenDuration then
        self.elapsedTime = self.elapsedTime + Time.deltaTime
        local currentDanceColor = Color.Lerp(self.initialColor, self.targetDanceColor,
            self.elapsedTime / self.tweenDuration)
        self.danceTexture.color = currentDanceColor
    else
        self.danceTexture.color = self.targetDanceColor
    end
end

local function GetPlatformPath()
    local platform = APPMAN:GetPlatformInt()
    if (platform == 1) then
        return "Windows"
    end
    if (platform == 2) then
        return "MacOS"
    end
    if (platform == 3) then
        return "Android"
    end
    if (platform == 4) then
        return "iOS"
    end

    return "Other/"
end

execute.onloaded = function()
    local platform = GetPlatformPath()
    local hash = ASSETMAN:LoadAssetBundle(execute.GetModulePath() .. "/modules/" .. platform .. "/flame")
    _BossDmgEffectPrefab = ASSETMAN:LoadGameObject(hash, "FlameParticle")

    FlameContainer = GameObject("FlameContainer")

    --Loading boss (if found)
    local bossFile = findFirstBossFile()
    local _charBoss = ACTORFACTORY:Create2D()
    if bossFile then
        _charBoss:LoadImage(bossFile)
    end
    _sprite = _charBoss.gameObject
    _charBoss.gameObject.transform.localPosition = Vector3(0, -2, 5)
    local sprite = _charBoss:GetSpriteRenderer()
    spriteChar = sprite

    MusicTimePanel = GameObject.Find("MusicTimePanel")
    MusicTimePanel_Pos = MusicTimePanel.transform.localPosition + Vector3(0, 10, 0)
    MusicTimePanel.transform.localPosition = MusicTimePanel_Pos

    -- Boss bar
    local BossBar = MusicTimePanel.transform:Find("Slider")
    local ClonedBossBar = GameObject.Instantiate(BossBar)
    ClonedBossBar.name = "BossBar"
    ClonedBossBar.transform:SetParent(MusicTimePanel.transform, false)
    ClonedBossBar.transform.localPosition = BossBar.transform.localPosition
    local ClonedBossBarFA = ClonedBossBar.transform:Find("Fill Area")
    local ClonedBossBarFACanvas = ClonedBossBarFA.gameObject:AddComponent(typeof(CS.UnityEngine.Canvas))
    ClonedBossBarFACanvas.overrideSorting = true
    ClonedBossBarFACanvas.sortingOrder = 2

    ClonedBossBarFill = ClonedBossBarFA.transform:Find("Fill")
    local ClonedBossBarFillCanvas = ClonedBossBarFill.gameObject:AddComponent(typeof(CS.UnityEngine.Canvas))
    ClonedBossBarFillCanvas.overrideSorting = true
    ClonedBossBarFillCanvas.sortingOrder = 4

    local TintBossBar = GameObject.Instantiate(ClonedBossBar)
    TintBossBar.name = "TintBossBar"
    TintBossBar.transform.localScale = Vector3(1.05, 1.5, 0)
    TintBossBar.transform:SetParent(MusicTimePanel.transform, false)
    TintBossBar.transform.localPosition = ClonedBossBar.transform.localPosition

    local TintBossBarFA = TintBossBar.transform:Find("Fill Area")
    local TintBossBarFAComp = TintBossBarFA:GetComponent(typeof(CS.UnityEngine.UI.Image))
    TintBossBarFAComp.color = Color(1, 1, 1, 0)
    TintBar = TintBossBarFAComp

    -- Tint boss bar
    local TintBossBarFAF = TintBossBarFA.transform:Find("Fill")
    GameObject.Destroy(TintBossBarFAF.gameObject)

    -- Time bar
    local TimeBar = BossBar
    TimeBar.transform.localPosition = TimeBar.transform.localPosition - Vector3(0, 19, 0)
    TimeBar.transform.localScale = Vector3(0.6, 1, 1)

    local TimeBarCanvas = TimeBar.gameObject:AddComponent(typeof(CS.UnityEngine.Canvas))
    TimeBarCanvas.overrideSorting = true
    TimeBarCanvas.sortingOrder = 1

    local TimeBarFA = TimeBar.transform:Find("Fill Area")
    TimeBarFA:GetComponent(typeof(CS.UnityEngine.UI.Image)).color = ColorRGBA(66, 0, 40, 1)
    local TimeBarFAF = TimeBarFA.transform:Find("Fill")
    TimeBarFAF:GetComponent(typeof(CS.UnityEngine.UI.Image)).color = ColorRGBA(221, 0, 133, 1)

    local BossBarSprite = MusicTimePanel.transform:Find("Image")
    BossBarSprite.gameObject.name = "BossBarSprite"

    local TimeImage = MusicTimePanel.transform:Find("Image")
    TimeImage.transform.localPosition = TimeImage.transform.localPosition - Vector3(-10, 53, 0)
    TimeImage.transform.localScale = Vector3(0.6, 0.6, 0.6)

    -- Boss bar marker
    local BossBarMarkerF = GameObject.Instantiate(ClonedBossBarFill)
    BossBarMarkerF.name = "BossBarMarker"
    _BossBarMarker = BossBarMarkerF
    BossBarMarkerF.transform:SetParent(ClonedBossBarFA.transform, false)
    local BossBarMarkerComp = BossBarMarkerF:GetComponent(typeof(CS.UnityEngine.UI.Image))
    BossBarMarkerComp.color = ColorRGBA(255, 233, 233, 1)
    local BossBarMarkerCanvas = BossBarMarkerF.gameObject:GetComponent(typeof(CS.UnityEngine.Canvas))
    BossBarMarkerCanvas.overrideSorting = true
    BossBarMarkerCanvas.sortingOrder = 3

    -- Boss bar division
    local notes = GAMESTATE:GetNotes()
    local attackNotes = 0

    for i = 0, notes.Length - 1 do
        if notes[i].IsAttack then
            attackNotes = attackNotes + 1
        end
    end

    BossBarDivision = 1 / attackNotes
end

local shakeTime = 0

local function RandomIncludeNegative(min, max)
    min = tonumber(min) or 0
    max = tonumber(max) or 0

    if min > max then
        min, max = max, min
    end

    return min + (max - min) * math.random()
end

local function DamageBoss()
    if spriteChar then
        colorTween1 = SpriteColorTween.new(spriteChar, Color(1, 0, 0, .8), Color(1, 1, 1, 1), .3)
    end
    damageTween = SpriteColorTween.new(TintBar, ColorRGBA(255, 64, 64, .6), ColorRGBA(255, 64, 64, 0), .7)

    if ClonedBossBarFill then
        ClonedBossBarFill.transform.anchorMax = ClonedBossBarFill.transform.anchorMax - Vector2(BossBarDivision, 0)
    end

    shakeTime = 0.1
end

local attackQueueLeft = {}
local attackQueueRight = {}
local lastFlameTimeLeft = 0
local lastFlameTimeRight = 0
local flameInterval = 0.2125
local damageDelay = 0.15
local damageQueue = {}

local function queueAttack(id, lane, noteType, judgeType, isAttack)
    if isAttack then
        if lane >= 0 and lane <= 2 then
            table.insert(attackQueueLeft, {
                id = id,
                lane = lane,
                noteType = noteType,
                judgeType = judgeType
            })
        elseif lane >= 4 and lane <= 6 then
            table.insert(attackQueueRight, {
                id = id,
                lane = lane,
                noteType = noteType,
                judgeType = judgeType
            })
        else
            if math.random() >= 0.5 then
                table.insert(attackQueueLeft, {
                    id = id,
                    lane = lane,
                    noteType = noteType,
                    judgeType = judgeType
                })
            else
                table.insert(attackQueueRight, {
                    id = id,
                    lane = lane,
                    noteType = noteType,
                    judgeType = judgeType
                })
            end
        end
    end
end

local function processNextAttack(attackQueue, lastFlameTime)
    if #attackQueue == 0 then
        return lastFlameTime
    end

    local currentTime = Time.time
    if currentTime - lastFlameTime >= flameInterval then
        lastFlameTime = currentTime

        local attackData = table.remove(attackQueue, 1)
        local lane = attackData.lane

        local Flame = GameObject.Instantiate(_BossDmgEffectPrefab)
        Flame.transform:SetParent(FlameContainer.transform, false)
        Flame.transform.localScale = Vector3(0.05, 0.05, 0.1)

        if lane >= 0 and lane <= 2 then
            Flame.transform.localPosition = Vector3(-5, -2, 0)
            Flame.transform.eulerAngles = Vector3(333, 0, 0)
        elseif lane >= 4 and lane <= 6 then
            Flame.transform.localPosition = Vector3(5, -2, 0)
            Flame.transform.eulerAngles = Vector3(333, 0, 180)
        else
            if math.random() >= 0.5 then
                Flame.transform.localPosition = Vector3(-5, -2, 0)
                Flame.transform.eulerAngles = Vector3(333, 0, 0)
            else
                Flame.transform.localPosition = Vector3(5, -2, 0)
                Flame.transform.eulerAngles = Vector3(333, 0, 180)
            end
        end

        -- Queue the damage call
        table.insert(damageQueue, {
            time = currentTime + damageDelay
        })
    end

    return lastFlameTime
end

local function processDamage()
    local currentTime = Time.time
    while #damageQueue > 0 and damageQueue[1].time <= currentTime do
        table.remove(damageQueue, 1)
        DamageBoss()
    end
end

local function ShakeBar()
    if MusicTimePanel == nil then
        return
    end

    if shakeTime > 0 then
        MusicTimePanel.transform.localPosition = Vector3(RandomIncludeNegative(MusicTimePanel_Pos.x - 3,
                MusicTimePanel_Pos.x + 3), RandomIncludeNegative(MusicTimePanel_Pos.y - 4, MusicTimePanel_Pos.y + 4),
            MusicTimePanel_Pos.z)
        shakeTime = shakeTime - Time.deltaTime
    else
        MusicTimePanel.transform.localPosition = MusicTimePanel_Pos
    end
end

execute.onHitNote = function(id, lane, noteType, judgeType, isAttack)
    if isAttack then
        queueAttack(id, lane, noteType, judgeType, isAttack)
    end
end

local bounceMirror = false
local bounceDebounce = false

execute.update = function()
    if colorTween1 ~= nil then
        colorTween1:Update()
    end

    if damageTween ~= nil then
        damageTween:Update()
    end

    lastFlameTimeLeft = processNextAttack(attackQueueLeft, lastFlameTimeLeft)
    lastFlameTimeRight = processNextAttack(attackQueueRight, lastFlameTimeRight)
    processDamage()

    if _sprite == nil then
        return
    end

    if _BossBarMarker and ClonedBossBarFill then
        local currBossHealth = ClonedBossBarFill.transform.anchorMax.x

        if BossBarMarkerDivision > currBossHealth then
            BossBarMarkerDivision = BossBarMarkerDivision - Time.deltaTime / 18
            _BossBarMarker.transform.anchorMax = Vector2(BossBarMarkerDivision, 1)
        end
    end

    ShakeBar()

    if math.floor(GAMESTATE:GetSongBeat()) % 4 == 0 then
        if not bounceDebounce then
            bounceMirror = not bounceMirror
            bounceDebounce = true
            if bounceMirror then
                _sprite.transform:DOScale(Vector3(1.05, 1.05, 1.05), 2):SetEase(CS.DG.Tweening.Ease.InOutQuad)
            else
                _sprite.transform:DOScale(Vector3(1, 1, 1), 2):SetEase(CS.DG.Tweening.Ease.InOutQuad)
            end
        end
    else
        bounceDebounce = false
    end
end

return execute
