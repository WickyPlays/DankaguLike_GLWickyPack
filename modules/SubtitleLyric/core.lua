--著者: Wicky

local File = CS.System.IO.File
local Directory = CS.System.IO.Directory
local UnityEngine = CS.UnityEngine
local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2
local Canvas = UnityEngine.Canvas

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

  for i, line in ipairs(lines) do
    local lyric = {}

    local id = tonumber(line)

    if id ~= nil then
      lyric.id = id

      local timecode = lines[i + 1]
      if timecode ~= nil then
        local startH, startM, startS, startMs, endH, endM, endS, endMs = timecode:match(
        "(%d+):(%d+):(%d+),(%d+)%s%-%-%>%s(%d+):(%d+):(%d+),(%d+)")
        lyric.startTime = timeToMs(startH, startM, startS, startMs)
        lyric.endTime = timeToMs(endH, endM, endS, endMs)
      end

      local lyricLine = lines[i + 2]
      if lyricLine ~= nil then
        lyric.lyricLine = lyricLine
      end

      table.insert(lyrics, lyric)

      i = i + 2
    end
  end

  return lyrics
end

execute.onloaded = function(e)
	parseSubtitle()

  local canvas = util.GetCanvas()
  local LyricJP = GameObject("LyricJP")
  LyricJP.gameObject.transform:SetParent(canvas.transform, false)
  LyricJP:AddComponent(typeof(UnityEngine.CanvasRenderer))
  _LyricJPText = LyricJP:AddComponent(typeof(UnityEngine.UI.Text))
  LyricJP.transform.anchorMin = Vector2(0.5, 1)
  LyricJP.transform.anchorMax = Vector2(0.5, 1)
  LyricJP.transform.pivot = Vector2(0.5, 4.7)
  LyricJP.transform.sizeDelta = Vector2(util.GetScreenWidth(), 260)
  _LyricJPText.font = util.GetFontJP()
  _LyricJPText.fontSize = 36
  _LyricJPText.alignment = UnityEngine.TextAnchor.UpperCenter
end

local currLyricIndex = 1

execute.update = function()
  local currentTimeMs = GAMESTATE:GetSongTime() * 1000 -- Convert seconds to milliseconds
  local currLyric = lyrics[currLyricIndex]

  if currLyric then
    if currentTimeMs >= currLyric.startTime and currentTimeMs <= currLyric.endTime then
      _LyricJPText.text = currLyric.lyricLine
    elseif currentTimeMs > currLyric.endTime then
      currLyricIndex = currLyricIndex + 1
    else
      _LyricJPText.text = ""
    end
  else
    _LyricJPText.text = ""
  end
end

return execute