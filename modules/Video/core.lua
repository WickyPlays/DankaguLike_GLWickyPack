--著者: Wicky

local Directory = CS.System.IO.Directory
local UnityEngine = CS.UnityEngine
local GameObject = UnityEngine.GameObject

local execute = {}
execute.active = true


local function findFirstFileWithExtension(directory, extension)
  local files = Directory.GetFiles(directory, "*" .. extension)

  if files == nil or files.Length == 0 then return nil end

  return files[0]
end

local function startVideo()
  local filePath = findFirstFileWithExtension(SONGMAN:GetSongDir(), '.mp4')
  if not filePath then return end

  local vidCanvas = ACTORFACTORY:CreateVideoCanvas()
	vidCanvas:SetVideoPath(filePath)
	vidCanvas:SetAutoMusicSync(true)
	vidCanvas:SetScreenMatchMode(1)
	vidCanvas:SetBrightness(execute.GetOption("brightness"))
	vidCanvas:Play()

	--Add black BG behind for bigger phone screen

	local RawImage = vidCanvas.gameObject:AddComponent(typeof(UnityEngine.UI.RawImage))
	RawImage.color = UnityEngine.Color(0,0,0)
end

execute.onloaded = function()
	startVideo()
end

return execute