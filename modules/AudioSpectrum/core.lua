--著者: Wicky

local execute = {}
execute.active = true

local coretype = nil

execute.onloaded = function()
    local type = execute.GetOption("type")
    if type == 1 then
        coretype = require("modules\\AudioSpectrum\\coretype1.lua")
    elseif type == 2 then
        coretype = require("modules\\AudioSpectrum\\coretype2.lua")
    end

    if coretype then
        coretype.onloaded()
    end
end

execute.update = function()
    if coretype then
        coretype.update()
    end
end

execute.ondestroy = function()
	package.loaded['modules\\AudioSpectrum\\coretype1.lua'] = nil
	_G['modules\\AudioSpectrum\\coretype1.lua'] = nil

    package.loaded['modules\\AudioSpectrum\\coretype2.lua'] = nil
    _G['modules\\AudioSpectrum\\coretype2.lua'] = nil
end

return execute
