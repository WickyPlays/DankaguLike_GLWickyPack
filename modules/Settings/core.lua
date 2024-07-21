local execute = {}
execute.active = true

local UnityEngine = CS.UnityEngine
local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color
local Canvas = UnityEngine.Canvas
local Text = UnityEngine.UI.Text
local Button = UnityEngine.UI.Button
local Image = UnityEngine.UI.Image
local RawImage = UnityEngine.UI.RawImage
local GraphicRaycaster = UnityEngine.UI.GraphicRaycaster
local SettingsCanvas = nil
local ModeButtons = nil

local defaultBtnSize = Vector2(400, 15)

local CreateButton = function(name, pos, size, color, text, sprite, clickListener)
  if SettingsCanvas == nil then return end
  local buttonObject = UnityEngine.GameObject(name)
  buttonObject:AddComponent(typeof(UnityEngine.RectTransform))
  buttonObject:AddComponent(typeof(UnityEngine.CanvasRenderer))
  local button = buttonObject:AddComponent(typeof(Button))
  local buttonImage = buttonObject:AddComponent(typeof(Image))

  buttonObject.transform:SetParent(SettingsCanvas.transform, false)

  local rectTransform = buttonObject:GetComponent(typeof(UnityEngine.RectTransform))
  rectTransform.anchoredPosition = pos or Vector2(0, 0)
  rectTransform.sizeDelta = size or Vector2(50, 50)
  buttonImage.color = color or UnityEngine.Color.white
  button.targetGraphic = buttonImage

  local buttonText = nil
  if text then
    local Label = GameObject(name .. "Label")
    Label.transform:SetParent(buttonObject.transform, false)
    buttonText = Label:AddComponent(typeof(Text))
    buttonText.text = text.text
    buttonText.font = util.GetFontJP()
    buttonText.fontSize = text.size
    buttonText.alignment = UnityEngine.TextAnchor.MiddleCenter
    buttonText.color = text.color
    buttonText.horizontalOverflow = CS.UnityEngine.HorizontalWrapMode.Overflow
  end

  if clickListener then
    button.onClick:AddListener(clickListener)
  end

  return {
    button = button,
    buttonObject = buttonObject,
    buttonImage = buttonImage,
    buttonText = buttonText
  }
end

local pageIndex = 1
local modules = {}
local xSide = -500
local xMid = 0
local y1 = -380
local y2 = -450
local optionPos = {
  {
    pos = Vector2(xSide, y1),
    size = defaultBtnSize
  },
  {
    pos = Vector2(xMid, y1),
    size = defaultBtnSize
  },
  {
    pos = Vector2(-xSide, y1),
    size = defaultBtnSize
  },
  {
    pos = Vector2(xSide, y2),
    size = defaultBtnSize
  },
  {
    pos = Vector2(xMid, y2),
    size = defaultBtnSize
  },
  {
    pos = Vector2(-xSide, y2),
    size = defaultBtnSize
  }
}

local GetModules = function()
  local newModules = {}
  local startIndex = (pageIndex - 1) * 6 + 1
  local endIndex = startIndex + 6

  for i = startIndex, endIndex - 1 do
    if modules[i] then
      table.insert(newModules, modules[i])
    end
  end

  return newModules
end

local RenderSettings = function()
  if SettingsCanvas == nil then return end
  if ModeButtons ~= nil then 
    GameObject.Destroy(ModeButtons)
  end

  ModeButtons = GameObject("ModeButtons")
  ModeButtons.transform:SetParent(SettingsCanvas.transform, false)
  
  local fontSize = 30
  if util.GetScreenWidth() < 1024 then
    fontSize = 27
  end

  for i, v in pairs(GetModules()) do

    local enabledText = "Off"
    if util.GetSettings(v, "enable") == 1 then
      enabledText = "On"
    end

    local modeBtn = CreateButton(v, optionPos[i].pos,
      optionPos[i].size,
      Color(1, 1, 1, 0), { text = v .. ": " .. enabledText, color = Color(1, 1, 1, 1), size = fontSize }, nil, nil)

    if modeBtn then
      modeBtn.buttonObject.transform:SetParent(ModeButtons.transform, false)
      modeBtn.button.onClick:AddListener(function()
        if util.GetSettings(v, "enable") == 1 then
          util.SetSettings(v, "enable", 0)
          modeBtn.buttonText.text = v .. ": Off"
        else
          util.SetSettings(v, "enable", 1)
          modeBtn.buttonText.text = v .. ": On"
        end
        util.SaveSettings()
      end)
    end
  end
end

local SwitchPage = function(delta)
  pageIndex = pageIndex + delta

  local maxPageIndex = math.ceil(#modules / 6)
  if pageIndex < 1 then
    pageIndex = maxPageIndex
  elseif pageIndex > maxPageIndex then
    pageIndex = 1
  end

  RenderSettings()
end

execute.onloaded = function()
  modules = util.GetModules()
  SettingsCanvas = util.CreateCanvas("WSettingsCanvas", 1)
  local canvasComp = SettingsCanvas:GetComponent(typeof(Canvas))
  canvasComp.renderMode = UnityEngine.RenderMode.ScreenSpaceOverlay
  canvasComp.sortingOrder = 50
  SettingsCanvas:AddComponent(typeof(GraphicRaycaster))

  local Panel = GameObject("Panel")
  Panel.transform:SetParent(SettingsCanvas.transform, false)
  local RawImage = Panel:AddComponent(typeof(RawImage))
  RawImage.transform.anchorMin = Vector2(0.05, 0)
  RawImage.transform.anchorMax = Vector2(0.95, 0.2)
  RawImage.transform.anchoredPosition = Vector2(0, 0)
  RawImage.transform.sizeDelta = Vector2(0, 0)
  RawImage.color = util.ColorRGBA(0, 0, 0, 0.8)

  CreateButton("PreviousButton", Vector2(xSide - 200, (y1 + y2) / 2), Vector2(50, 50),
    Color(1, 1, 1, 0), { text = "<", color = Color(1, 1, 1, 1), size = 40 }, nil,
    function()
      SwitchPage(-1)
    end
  )

  CreateButton("NextButton", Vector2(-xSide + 200, (y1 + y2) / 2), Vector2(50, 50),
    Color(1, 1, 1, 0), { text = ">", color = Color(1, 1, 1, 1), size = 40 }, nil,
    function()
      SwitchPage(1)
    end
  )

  RenderSettings()

  SettingsCanvas.gameObject:SetActive(false)
end

execute.onPause = function()
  if SettingsCanvas then
    SettingsCanvas.gameObject:SetActive(true)
  end
end

execute.onResume = function()
  if SettingsCanvas then
    SettingsCanvas.gameObject:SetActive(false)
  end
end

return execute
