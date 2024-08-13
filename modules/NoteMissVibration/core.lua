--著者: Wicky

local execute = {}
execute.active = true

execute.onMissedNote = function(id, lane, noteType)
	if util.IsPlatformMobile() then
		CS.UnityEngine.Handheld.Vibrate()
	end
end

return execute