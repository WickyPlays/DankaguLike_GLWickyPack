--著者: Wicky

local execute = {}
execute.active = true

local GameObject = CS.UnityEngine.GameObject
local Vector3 = CS.UnityEngine.Vector3
local Vector2 = CS.UnityEngine.Vector2
local Color = CS.UnityEngine.Color

local WickyCanvasTE = nil

local SAMPLE_NUM = 8192
local BAR_COUNT = 30
local _scale = 55
local smoothingFactor = 0.5
local globalMaxLevel = 0
local maxPillarHeight = 80
local nonLinearFactor = 0.6
local minThreshold = 30
local sharpness = 1

local FFT_WINDOW = CS.UnityEngine.FFTWindow.Hamming
local _spectrumData = {}

local _nodes = {}

local GAP = 0.8
local UI_X_MIN = -200
local UI_X_MAX = 200

local function CreateCube()
    local totalWidth = UI_X_MAX - UI_X_MIN
    local widthNode = totalWidth / BAR_COUNT

    local TimerHeight = GameObject.Find("MusicTimePanel")

    for i = 1, BAR_COUNT do
        local xPos = UI_X_MIN + ((i - 1) * widthNode)

        local Node = GameObject("Node")
        Node.transform:SetParent(WickyCanvasTE.transform, false)
        local NodeImg = Node:AddComponent(typeof(CS.UnityEngine.UI.Image))
        NodeImg.color = Color(1, 1, 1, 0.3)
        NodeImg.transform.pivot = Vector2(0, 1)

        if util.IsPlatformMobile() then
            NodeImg.transform.anchoredPosition = Vector2(xPos,
                TimerHeight.transform.localPosition.y + TimerHeight.transform.sizeDelta.y / 2.5)
        else
            NodeImg.transform.anchoredPosition = Vector2(xPos,
            TimerHeight.transform.localPosition.y - TimerHeight.transform.sizeDelta.y / 2)
        end
        
        NodeImg.transform.localScale = Vector3(1 * GAP, 1, 1)
        NodeImg.transform.sizeDelta = Vector2(widthNode, 0)

        _nodes[i] = NodeImg
    end
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function Clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

local function Pow(value, exp)
    return value ^ exp
end

local function CalculateAverage(barIndex, count)
    local average = 0
    local sampleCount = math.floor(math.log(barIndex + 1) / math.log(2)) * 2

    if barIndex == BAR_COUNT then
        sampleCount = 0
    end

    for j = 1, sampleCount do
        if count >= SAMPLE_NUM then break end
        average = average + _spectrumData[count + 1] * (count + 1)
        count = count + 1
    end

    if sampleCount > 0 then
        average = average / sampleCount
    end

    -- Return the calculated average and the updated count value
    return average, count
end

local function ProcessCubes(isMaxLevelPass)
    local maxLevel = 0
    local count = 0

    for i = 0, BAR_COUNT - 1 do
        local average
        average, count = CalculateAverage(i, count)

        -- Apply a transformation to ensure low values have a higher impact
        average = Pow(average, sharpness)
        local level = average * _scale * 0.01

        if isMaxLevelPass then
            if level > maxLevel then
                maxLevel = level
            end
        else
            -- Normalize and apply non-linear scaling
            if globalMaxLevel > 0 then
                level = Clamp(level / globalMaxLevel, 0, 1) * globalMaxLevel
            end

            level = Pow(level, nonLinearFactor) * maxPillarHeight
            level = math.min(level, maxPillarHeight)

            -- Smooth the scaling of the cubes
            local previousScale = _nodes[i + 1].transform.sizeDelta
            local newScaleY = Lerp(previousScale.y, level, smoothingFactor)
            maxLevel = newScaleY
            _nodes[i + 1].transform.sizeDelta = Vector2(previousScale.x, newScaleY)
        end
    end

    -- Do not let the silent bar (found in first ones) remain silent the whole way
    for i = 1, math.floor(BAR_COUNT / 3) do
        local node = _nodes[i]
        if node ~= nil then
            local mirroredIndex = BAR_COUNT - i + 1
            local mirrorNode = _nodes[mirroredIndex]
    
            local nodeY = node.transform.sizeDelta.y
            local mirrorY = mirrorNode.transform.sizeDelta.y
    
            if nodeY < minThreshold then
                local newScaleY = Lerp(nodeY, mirrorY, smoothingFactor)
                node.transform.sizeDelta = Vector2(node.transform.sizeDelta.x, newScaleY)
            end
        end
    end

    return maxLevel
end


execute.onloaded = function()

    if util.IsPlatformMobile() then
        UI_X_MIN = -250
        UI_X_MAX = 250
    end

    WickyCanvasTE = util.CreateCanvas("WickyCanvasAS", 5)

    for i = 0, SAMPLE_NUM do
        _spectrumData[i] = 0
    end
    CreateCube()
end

execute.update = function()
    _spectrumData = UTIL:GetSpectrumData(SAMPLE_NUM, 0, FFT_WINDOW)

    if _spectrumData == nil then
        return
    end

    local maxLevel = ProcessCubes(true)
    globalMaxLevel = Lerp(globalMaxLevel, maxLevel, smoothingFactor)
    ProcessCubes(false)
end

return execute
