-- Author: Wicky

local execute = {}
execute.active = true

local GameObject = CS.UnityEngine.GameObject
local Vector3 = CS.UnityEngine.Vector3
local Vector2 = CS.UnityEngine.Vector2
local Color = CS.UnityEngine.Color

local visualizationCanvas = nil

local SAMPLE_COUNT = 8192
local BAR_COUNT = 25
local SCALE_FACTOR = 55
local SMOOTHING_FACTOR = 0.5
local globalMaxAmplitude = 0
local MAX_BAR_HEIGHT = 80
local NON_LINEAR_FACTOR = 0.6
local SHARPNESS = 1

local FFT_WINDOW_TYPE = CS.UnityEngine.FFTWindow.BlackmanHarris
local spectrumData = {}

local barNodes = {}

local BAR_GAP = 0.8
local UI_X_MIN = -200
local UI_X_MAX = 200

local function CreateBars()
    local totalWidth = UI_X_MAX - UI_X_MIN
    local barWidth = totalWidth / BAR_COUNT

    local musicTimePanel = GameObject.Find("MusicTimePanel")

    for i = 1, BAR_COUNT do
        local xPosition = UI_X_MAX - (i * barWidth)

        local barNode = GameObject("BarNode")
        barNode.transform:SetParent(visualizationCanvas.transform, false)
        local barImage = barNode:AddComponent(typeof(CS.UnityEngine.UI.Image))
        barImage.color = Color(1, 1, 1, 0.3)
        barImage.transform.pivot = Vector2(0, 1)

        if util.IsPlatformMobile() then
            barImage.transform.anchoredPosition = Vector2(xPosition,
                musicTimePanel.transform.localPosition.y + musicTimePanel.transform.sizeDelta.y / 2.5)
        else
            barImage.transform.anchoredPosition = Vector2(xPosition,
                musicTimePanel.transform.localPosition.y - musicTimePanel.transform.sizeDelta.y / 2)
        end

        barImage.transform.localScale = Vector3(1 * BAR_GAP, 1, 1)
        barImage.transform.sizeDelta = Vector2(barWidth, 0)

        barNodes[i] = barImage
    end
end

local function Interpolate(a, b, t)
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

local function Power(value, exponent)
    return value ^ exponent
end

local function ComputeAverageAmplitude(barIndex, sampleIndex)
    local averageAmplitude = 0
    local sampleCount = math.floor(math.log(barIndex + 1) / math.log(2)) * 2

    if barIndex == BAR_COUNT then
        sampleCount = 0
    end

    for j = 1, sampleCount do
        if sampleIndex >= SAMPLE_COUNT then break end
        averageAmplitude = averageAmplitude + spectrumData[sampleIndex + 1] * (sampleIndex + 1)
        sampleIndex = sampleIndex + 1
    end

    if sampleCount > 0 then
        averageAmplitude = averageAmplitude / sampleCount
    end

    return averageAmplitude, sampleIndex
end

local function UpdateBars(isMaxAmplitudePass)
    local maxAmplitude = 0
    local sampleIndex = 0

    for i = 0, BAR_COUNT - 1 do
        local averageAmplitude
        averageAmplitude, sampleIndex = ComputeAverageAmplitude(i, sampleIndex)

        -- Apply transformation to emphasize lower values
        averageAmplitude = Power(averageAmplitude, SHARPNESS)
        local barHeight = averageAmplitude * SCALE_FACTOR * 0.01
        if barHeight < 0.03 then
            barHeight = 0.05
        end

        if isMaxAmplitudePass then
            if barHeight > maxAmplitude then
                maxAmplitude = barHeight
            end
        else
            -- Normalize and apply non-linear scaling
            if globalMaxAmplitude > 0 then
                barHeight = Clamp(barHeight / globalMaxAmplitude, 0, 1) * globalMaxAmplitude
            end

            barHeight = Power(barHeight, NON_LINEAR_FACTOR) * MAX_BAR_HEIGHT
            barHeight = math.min(barHeight, MAX_BAR_HEIGHT)

            -- Smooth the scaling of the bars
            local previousScale = barNodes[i + 1].transform.sizeDelta
            local newBarHeight = Interpolate(previousScale.y, barHeight, SMOOTHING_FACTOR)
            maxAmplitude = newBarHeight
            barNodes[i + 1].transform.sizeDelta = Vector2(previousScale.x, newBarHeight)
        end
    end

    return maxAmplitude
end

execute.onloaded = function()
    if util.IsPlatformMobile() then
        UI_X_MIN = -250
        UI_X_MAX = 250
    end

    visualizationCanvas = util.CreateCanvas("WickyCanvasAS", 5)

    for i = 0, SAMPLE_COUNT do
        spectrumData[i] = 0
    end
    CreateBars()
end

execute.update = function()
    spectrumData = UTIL:GetSpectrumData(SAMPLE_COUNT, 0, FFT_WINDOW_TYPE)

    if spectrumData == nil then
        return
    end

    local maxAmplitude = UpdateBars(true)
    globalMaxAmplitude = Interpolate(globalMaxAmplitude, maxAmplitude, SMOOTHING_FACTOR)
    UpdateBars(false)
end

return execute
