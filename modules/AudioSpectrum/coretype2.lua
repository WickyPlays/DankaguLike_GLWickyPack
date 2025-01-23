-- Author: Wicky

local execute = {}
execute.active = true

local UnityEngine = CS.UnityEngine
local GameObject = CS.UnityEngine.GameObject
local Vector3 = CS.UnityEngine.Vector3
local Vector2 = CS.UnityEngine.Vector2
local Color = CS.UnityEngine.Color

local visualizationCanvas = nil
local rightVisualizationCanvas = nil

local SAMPLE_COUNT = 8192
local BAR_COUNT = 50
local SCALE_FACTOR = 65
local SMOOTHING_FACTOR = 0.5
local globalMaxAmplitude = 0
local MAX_BAR_HEIGHT = 100
local NON_LINEAR_FACTOR = 0.6
local SHARPNESS = 1

local FFT_WINDOW_TYPE = CS.UnityEngine.FFTWindow.BlackmanHarris
local spectrumData = {}

local barNodes = {}
local rightBarNodes = {}

local BAR_GAP = 0.8
local UI_Y_MIN = -1080 / 2
local UI_Y_MAX = 1080 / 2

local function CreateBars(targetBarNodes, targetCanvas, isRightSide)
    local totalHeight = UI_Y_MAX - UI_Y_MIN
    local barHeight = totalHeight / BAR_COUNT

    local musicTimePanel = GameObject.Find("MusicTimePanel")

    for i = 1, BAR_COUNT do
        local yPosition
        if isRightSide then
            yPosition = UI_Y_MAX - ((BAR_COUNT - (i - 1)) * barHeight)
        else
            yPosition = UI_Y_MAX - (i * barHeight)
        end

        local barNode = GameObject("BarNode")
        barNode.transform:SetParent(targetCanvas.transform, false)
        local barImage = barNode:AddComponent(typeof(CS.UnityEngine.UI.Image))
        barImage.color = Color(1, 1, 1, 0.3)
        barImage.transform.pivot = Vector2(0, 0)

        local xOffset = isRightSide and
            (musicTimePanel.transform.localPosition.x + musicTimePanel.transform.sizeDelta.x / 2.5) or
            (musicTimePanel.transform.localPosition.x - musicTimePanel.transform.sizeDelta.x / 2)

        barImage.transform.anchoredPosition = Vector2(xOffset, yPosition)
        barImage.transform.localScale = Vector3(1, 1 * BAR_GAP, 1)
        barImage.transform.sizeDelta = Vector2(0, barHeight)

        targetBarNodes[i] = barImage
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

local function UpdateBars(isMaxAmplitudePass, targetBarNodes)
    local maxAmplitude = 0
    local sampleIndex = 0

    for i = 0, BAR_COUNT - 1 do
        local averageAmplitude
        averageAmplitude, sampleIndex = ComputeAverageAmplitude(i, sampleIndex)

        -- Apply transformation to emphasize lower values
        averageAmplitude = Power(averageAmplitude, SHARPNESS)
        local barWidth = averageAmplitude * SCALE_FACTOR * 0.01
        if barWidth < 0.03 then
            barWidth = 0.05
        end

        if isMaxAmplitudePass then
            if barWidth > maxAmplitude then
                maxAmplitude = barWidth
            end
        else
            -- Normalize and apply non-linear scaling
            if globalMaxAmplitude > 0 then
                barWidth = Clamp(barWidth / globalMaxAmplitude, 0, 1) * globalMaxAmplitude
            end

            barWidth = Power(barWidth, NON_LINEAR_FACTOR) * MAX_BAR_HEIGHT
            barWidth = math.min(barWidth, MAX_BAR_HEIGHT)

            -- Smooth the scaling of the bars
            local previousScale = targetBarNodes[i + 1].transform.sizeDelta
            local newBarWidth = Interpolate(previousScale.x, barWidth, SMOOTHING_FACTOR)
            maxAmplitude = newBarWidth
            targetBarNodes[i + 1].transform.sizeDelta = Vector2(newBarWidth, previousScale.y)
        end
    end

    return maxAmplitude
end

execute.onloaded = function()
    if util.IsPlatformMobile() then
        UI_Y_MIN = -250
        UI_Y_MAX = 250
    end

    local canvasContainer = util.CreateCanvas("WickyCanvasASContainer", 5)

    -- Create left-side visualization canvas
    visualizationCanvas = util.CreateCanvas("WickyCanvasAS", 5)
    visualizationCanvas.transform:SetParent(canvasContainer.transform, false)

    local visualizationCanvasC = visualizationCanvas:GetComponent(typeof(UnityEngine.Canvas))
    visualizationCanvasC.renderMode = CS.UnityEngine.RenderMode.ScreenSpaceOverlay

    visualizationCanvas.transform.eulerAngles = Vector3(0, 0, 0)
    visualizationCanvas.transform.localScale = Vector3(1, 1, 1)

    -- Create right-side visualization canvas
    rightVisualizationCanvas = util.CreateCanvas("WickyCanvasASRight", 5)
    rightVisualizationCanvas.transform:SetParent(canvasContainer.transform, false)

    local rightVisualizationCanvasC = rightVisualizationCanvas:GetComponent(typeof(UnityEngine.Canvas))
    rightVisualizationCanvasC.renderMode = CS.UnityEngine.RenderMode.ScreenSpaceOverlay

    rightVisualizationCanvas.transform.eulerAngles = Vector3(0, 180, 0)
    rightVisualizationCanvas.transform.localScale = Vector3(1, 1, 1)

    for i = 0, SAMPLE_COUNT do
        spectrumData[i] = 0
    end

    -- Create bars for both canvases
    CreateBars(barNodes, visualizationCanvas, false)
    CreateBars(rightBarNodes, rightVisualizationCanvas, true)
end

execute.update = function()
    spectrumData = UTIL:GetSpectrumData(SAMPLE_COUNT, 0, FFT_WINDOW_TYPE)

    if spectrumData == nil then
        return
    end

    visualizationCanvas.transform.localPosition = Vector3(0, 0, 0)
    visualizationCanvas.transform.pivot = Vector2(0.895, 0.5)

    rightVisualizationCanvas.transform.localPosition = Vector3(0, 0, 0)
    rightVisualizationCanvas.transform.pivot = Vector2(1.175, 0.5)

    local maxAmplitude = UpdateBars(true, barNodes)
    globalMaxAmplitude = Interpolate(globalMaxAmplitude, maxAmplitude, SMOOTHING_FACTOR)
    UpdateBars(false, barNodes)

    maxAmplitude = UpdateBars(true, rightBarNodes)
    globalMaxAmplitude = Interpolate(globalMaxAmplitude, maxAmplitude, SMOOTHING_FACTOR)
    UpdateBars(false, rightBarNodes)
end

return execute