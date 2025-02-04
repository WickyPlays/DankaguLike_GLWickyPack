--著者: Wicky

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

local btnSprite, btnOkSprite
local defaultBtnSize = Vector2(400, 15)
local buttonSpacing = 400

-- Helper function to initialize and add components to GameObjects
local function AddComponent(gameObject, componentType)
  return gameObject:AddComponent(typeof(componentType))
end

local function CreateButton(name, pos, size, color, text, sprite, clickListener)
  if not SettingsCanvas then return end

  local buttonObject = GameObject(name)
  AddComponent(buttonObject, UnityEngine.RectTransform)
  AddComponent(buttonObject, UnityEngine.CanvasRenderer)
  local button = AddComponent(buttonObject, Button)
  local buttonImage = AddComponent(buttonObject, Image)

  buttonObject.transform:SetParent(SettingsCanvas.transform, false)

  local rectTransform = buttonObject:GetComponent(typeof(UnityEngine.RectTransform))
  rectTransform.anchoredPosition = pos or Vector2(0, 0)
  rectTransform.sizeDelta = size or Vector2(50, 50)
  buttonImage.color = color or UnityEngine.Color.white
  button.targetGraphic = buttonImage

  local btnImg = GameObject(name .. "Image")
  btnImg.transform:SetParent(buttonObject.transform, false)
  local btnImage = AddComponent(btnImg, Image)
  btnImage.sprite = sprite or btnSprite
  btnImg.transform.sizeDelta = Vector2(350, 100)

  local buttonText
  if text then
    local label = GameObject(name .. "Label")
    label.transform:SetParent(btnImg.transform, false)
    buttonText = AddComponent(label, Text)
    buttonText.text = util.GetString(text.text)
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
    buttonImage = btnImage,
    buttonText = buttonText
  }
end

local modules = {}

local function RenderSettings()
  if not SettingsCanvas then return end

  if ModeButtons then
    GameObject.Destroy(ModeButtons)
  end

  ModeButtons = GameObject("ModeButtons")
  ModeButtons.transform:SetParent(SettingsCanvas.transform, false)

  local fontSize = util.GetScreenWidth() < 1024 and 27 or 30

  for i, v in ipairs(modules) do
    local isEnabled = util.GetSettings(v, "enable") == 1

    local pos = Vector2((i - 1) * buttonSpacing - (#modules - 1) * buttonSpacing / 1.95, 0)
    local modeBtn -- Declare modeBtn here to make it accessible inside the function

    modeBtn = CreateButton(v, pos, defaultBtnSize, Color(1, 1, 1, 0),
      { text = v, color = Color(0, 0, 0, 1), size = fontSize },
      isEnabled and btnOkSprite or btnSprite,
      function()
        local currentState = util.GetSettings(v, "enable")
        local newState = 1 - currentState
        util.SetSettings(v, "enable", newState)

        if modeBtn and modeBtn.buttonText and modeBtn.buttonImage then
          modeBtn.buttonText.text = util.GetString(v)
          modeBtn.buttonImage.sprite = newState == 1 and btnOkSprite or btnSprite
        end

        util.SaveSettings()
      end)

    if modeBtn then
      modeBtn.buttonObject.transform:SetParent(ModeButtons.transform, false)
    end
  end
end

execute.onloaded = function()
  local spriteObj = CS.UnityEngine.Resources.FindObjectsOfTypeAll(typeof(UnityEngine.Sprite))

  for i = 0, spriteObj.Length - 1 do
    if spriteObj[i].name == "white_design_button" then
      btnSprite = spriteObj[i]
    elseif spriteObj[i].name == "ok_button" then
      btnOkSprite = spriteObj[i]
    end
  end

  modules = util.GetModules()
  SettingsCanvas = util.CreateCanvas("WSettingsCanvas", 1)
  local canvasComp = SettingsCanvas:GetComponent(typeof(Canvas))
  canvasComp.renderMode = UnityEngine.RenderMode.ScreenSpaceOverlay
  canvasComp.sortingOrder = 50
  AddComponent(SettingsCanvas, GraphicRaycaster)

  local panel = GameObject("SettingsPanel")
  panel.transform:SetParent(SettingsCanvas.transform, false)
  local panelRawImage = AddComponent(panel, RawImage)
  panelRawImage.transform.anchorMin = Vector2(0, 0)
  panelRawImage.transform.anchorMax = Vector2(1, 0.22)
  panelRawImage.transform.anchoredPosition = Vector2(0, 0)
  panelRawImage.transform.sizeDelta = Vector2(0, 0)
  panelRawImage.color = util.ColorRGBA(0, 0, 0, 0.6)

  local title = GameObject("Title")
  title.transform:SetParent(SettingsCanvas.transform, false)
  local titleText = AddComponent(title, Text)
  titleText.text = "WickyPack 3.1.0 - " .. util.GetString("Settings")
  titleText.font = util.GetFontJP()
  titleText.fontSize = 30
  titleText.alignment = UnityEngine.TextAnchor.MiddleCenter
  titleText.color = Color(1, 1, 1, 1)
  titleText.horizontalOverflow = CS.UnityEngine.HorizontalWrapMode.Overflow
  title.transform.anchoredPosition = Vector2(0, -340)

  RenderSettings()

  local scrollView = GameObject("ScrollView")
  scrollView.transform:SetParent(SettingsCanvas.transform, false)
  local scrollRect = AddComponent(scrollView, UnityEngine.UI.ScrollRect)
  scrollRect.transform.anchorMin = Vector2(0.1, 0)
  scrollRect.transform.anchorMax = Vector2(0.9, 0.22)
  scrollRect.transform.anchoredPosition = Vector2(0, 0)
  scrollRect.transform.sizeDelta = Vector2(0, 0)
  scrollRect.vertical = false
  scrollRect.viewport = panel.transform

  ModeButtons.transform:SetParent(scrollView.transform, false)
  AddComponent(ModeButtons, GraphicRaycaster)
  ModeButtons.transform.sizeDelta = Vector2(#modules * defaultBtnSize.x + buttonSpacing / 2, 100)

  scrollRect.content = ModeButtons.transform
  scrollRect.normalizedPosition = Vector2(0, 0.5)
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
