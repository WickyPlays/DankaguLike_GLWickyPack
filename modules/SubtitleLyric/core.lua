local File = CS.System.IO.File
local Directory = CS.System.IO.Directory
local UnityEngine = CS.UnityEngine
local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2

local _Lyric1Text, _Lyric2Text

local execute = {}
execute.active = true

local lyrics = {}

local function findFirstFileWithExtension(directory, extension)
  local files = Directory.GetFiles(directory, "*" .. extension)

  if files == nil or files.Length == 0 then return nil end

  return files[0]
end

local function parseSubtitle()
  local filePath = findFirstFileWithExtension(SONGMAN:GetSongDir(), '.srt')
  if not filePath then return end

  --Line file reading here
  local fileContents = File.ReadAllText(filePath)
  local lines = {}
  for line in fileContents:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  --Subtitle parsing here

  local function timeToMs(hours, minutes, seconds, milliseconds)
    return (tonumber(hours) * 3600 + tonumber(minutes) * 60 + tonumber(seconds)) * 1000 + tonumber(milliseconds)
  end

  local i = 1
  while i <= #lines do
    local lyric = {}

    local id = tonumber(lines[i])

    if id ~= nil then
      lyric.id = id

      local timecode = lines[i + 1]
      if timecode ~= nil then
        local startH, startM, startS, startMs, endH, endM, endS, endMs = timecode:match(
          "(%d+):(%d+):(%d+),(%d+)%s%-%-%>%s(%d+):(%d+):(%d+),(%d+)")
        lyric.startTime = timeToMs(startH, startM, startS, startMs)
        lyric.endTime = timeToMs(endH, endM, endS, endMs)
      end

      lyric.lyricLine1 = lines[i + 2] or ""  -- First lyric line

      -- Check for a second lyric line under the same timestamp
      local nextLine = lines[i + 3]
      if nextLine and nextLine:match("^%d+$") == nil then
        lyric.lyricLine2 = nextLine
        i = i + 1 -- Skip the second lyric line in the loop
      else
        lyric.lyricLine2 = "" -- No second line
      end

      table.insert(lyrics, lyric)

      i = i + 2 -- Move to the next block
    end
    i = i + 1
  end

  return lyrics
end

execute.onloaded = function(e)
  parseSubtitle()

  local canvas = util.GetCanvas()

  local Lyric1 = GameObject("Lyric1")
  Lyric1.gameObject.transform:SetParent(canvas.transform, false)
  Lyric1:AddComponent(typeof(UnityEngine.CanvasRenderer))
  _Lyric1Text = Lyric1:AddComponent(typeof(UnityEngine.UI.Text))
  Lyric1.transform.anchorMin = Vector2(0.5, 1)
  Lyric1.transform.anchorMax = Vector2(0.5, 1)
  Lyric1.transform.pivot = Vector2(0.5, 4.65)
  Lyric1.transform.sizeDelta = Vector2(util.GetScreenWidth(), 260)
  _Lyric1Text.font = util.GetFontJP()
  _Lyric1Text.fontSize = 36
  _Lyric1Text.alignment = UnityEngine.TextAnchor.UpperCenter

  local Lyric2 = GameObject("Lyric2")
  Lyric2.gameObject.transform:SetParent(canvas.transform, false)
  Lyric2:AddComponent(typeof(UnityEngine.CanvasRenderer))
  _Lyric2Text = Lyric2:AddComponent(typeof(UnityEngine.UI.Text))
  Lyric2.transform.anchorMin = Vector2(0.5, 1)
  Lyric2.transform.anchorMax = Vector2(0.5, 1)
  Lyric2.transform.pivot = Vector2(0.5, 4.85)
  Lyric2.transform.sizeDelta = Vector2(util.GetScreenWidth(), 260)
  _Lyric2Text.font = util.GetFontJP()
  _Lyric2Text.fontSize = 34
  _Lyric2Text.alignment = UnityEngine.TextAnchor.UpperCenter
end

local currLyricIndex = 1

execute.update = function()
  local currentTimeMs = GAMESTATE:GetSongTime() * 1000 -- Convert seconds to milliseconds
  local currLyric = lyrics[currLyricIndex]

  if currLyric then
    if currentTimeMs >= currLyric.startTime and currentTimeMs <= currLyric.endTime then
      _Lyric1Text.text = currLyric.lyricLine1
      _Lyric2Text.text = currLyric.lyricLine2
    elseif currentTimeMs > currLyric.endTime then
      currLyricIndex = currLyricIndex + 1
    else
      _Lyric1Text.text = ""
      _Lyric2Text.text = ""
    end
  else
    _Lyric1Text.text = ""
    _Lyric2Text.text = ""
  end
end

return execute
