local UnityEngine = CS.UnityEngine
local GameObject = UnityEngine.GameObject
local TMPro = CS.TMPro
local RectTransform = UnityEngine.RectTransform

local execute = {}
execute.active = true

local FontJP = nil
local noteTextEntries = {}
local TextSize = 0.35
local ZThreshold = 0.1

execute.onloaded = function()
  TextSize = execute.GetOption("size") or 0.35
  FontJP = util.GetFontJP()
  if not execute.textCanvas then
    execute.textCanvas = GameObject("WPNoteCountCanvas")
    local canvas = execute.textCanvas:AddComponent(typeof(UnityEngine.Canvas))
    canvas.renderMode = UnityEngine.RenderMode.WorldSpace
    canvas.sortingOrder = 10

    local canvasTransform = execute.textCanvas:GetComponent(typeof(RectTransform))
    canvasTransform.sizeDelta = UnityEngine.Vector2(100, 100)
    canvasTransform.localScale = UnityEngine.Vector3(2, 2, 2)
    execute.textCanvas:AddComponent(typeof(UnityEngine.CanvasRenderer))

    local textObj = GameObject("NoteTextRoot")
    textObj.transform:SetParent(execute.textCanvas.transform)

    local textComponent = textObj:AddComponent(typeof(TMPro.TextMeshProUGUI))
    textComponent.font = FontJP
    textComponent.fontSize = 3
    textComponent.alignment = TMPro.TextAlignmentOptions.Center
    textComponent.color = UnityEngine.Color.white
    textComponent.enableWordWrapping = false
    textComponent.overflowMode = TMPro.TextOverflowModes.Overflow

    local rectTransform = textObj:GetComponent(typeof(RectTransform))
    rectTransform.sizeDelta = UnityEngine.Vector2(10, 10)
    rectTransform.localPosition = UnityEngine.Vector3(0, 0, 0)
  end
end

execute.update = function()
  for i = #noteTextEntries, 1, -1 do
    local entry = noteTextEntries[i]
    if entry.noteObj and entry.textObj and entry.noteObj.activeInHierarchy then
      local position = entry.noteObj.transform.position
      if math.abs(position.z) < ZThreshold then
        GameObject.Destroy(entry.textObj)
        table.remove(noteTextEntries, i)
      else
        -- Set position with a small z-offset to ensure it renders in front
        entry.textObj.transform.position = position + UnityEngine.Vector3(0, 0.22, -0.1)
        entry.textObj.transform.localScale = UnityEngine.Vector3(TextSize, TextSize, TextSize)
      end
    else
      if entry.textObj then
        GameObject.Destroy(entry.textObj)
      end
      table.remove(noteTextEntries, i)
    end
  end
end

execute.onSpawnNote = function(noteController)
  local index = noteController.NoteIndex
  local noteObj = noteController.gameObject

  for i, entry in ipairs(noteTextEntries) do
    if entry.noteObj == noteObj then
      entry.textObj:GetComponent(typeof(TMPro.TextMeshPro)).text = tostring(index)
      return
    end
  end

  local textObj = GameObject("NoteText_" .. index)
  textObj.transform:SetParent(execute.textCanvas.transform)

  local textComponent = textObj:AddComponent(typeof(TMPro.TextMeshPro))
  textComponent.text = tostring(index)
  textComponent.font = FontJP
  textComponent.fontSize = 3
  textComponent.alignment = TMPro.TextAlignmentOptions.Center
  textComponent.color = UnityEngine.Color.white
  textComponent.enableWordWrapping = false
  textComponent.overflowMode = TMPro.TextOverflowModes.Overflow

  -- Set sorting layer and order
  local renderer = textObj:GetComponent(typeof(UnityEngine.Renderer))
  if renderer then
    renderer.sortingOrder = 10
  end

  local rectTransform = textObj:GetComponent(typeof(RectTransform))
  rectTransform.sizeDelta = UnityEngine.Vector2(10, 10)
  rectTransform.localPosition = UnityEngine.Vector3(0, 0, 0)

  textObj.transform.position = noteObj.transform.position + UnityEngine.Vector3(0, 0.22, -0.1)
  textObj.transform.localScale = UnityEngine.Vector3(TextSize, TextSize, TextSize)

  table.insert(noteTextEntries, {
    noteObj = noteObj,
    textObj = textObj
  })
end

return execute
