local ini_parser = {};

function ini_parser.load(fileName)
	assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
	local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName);
	local data = { __order = {} };
	local current_section = nil;

	for line in file:lines() do
		-- Capture empty lines
		if line:match('^%s*$') then
			table.insert(data.__order, { type = "empty" });
		-- Capture comments
		elseif line:match('^%s*;.*$') then
			local comment = line:match('^(%s*;.*)$');
			table.insert(data.__order, { type = "comment", comment = comment, section = current_section });
		else
			local tempSection = line:match('^%[([^%[%]]+)%]$');
			if tempSection then
				current_section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
				if not data[current_section] then
					data[current_section] = { __order = {} };
					table.insert(data.__order, { type = "section", section = current_section });
				end
			end
			local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
			if param and value ~= nil then
				if tonumber(value) then
					value = tonumber(value);
				elseif value == 'true' then
					value = true;
				elseif value == 'false' then
					value = false;
				end
				if tonumber(param) then
					param = tonumber(param);
				end
				data[current_section][param] = value;
				table.insert(data[current_section].__order, param);
				table.insert(data.__order, { type = "pair", section = current_section, param = param, value = value });
			end
		end
	end
	file:close();
	return data;
end

function ini_parser.save(fileName, data)
	assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
	assert(type(data) == 'table', 'Parameter "data" must be a table.');
	local file = assert(io.open(fileName, 'w+b'), 'Error loading file :' .. fileName);
	local contents = '';
	local order = data.__order or {};

	for _, item in ipairs(order) do
		if item.type == "empty" then
			contents = contents .. '\n';
		elseif item.type == "comment" then
			contents = contents .. item.comment .. '\n';
		elseif item.type == "section" then
			contents = contents .. ('[%s]\n'):format(item.section);
		elseif item.type == "pair" then
			contents = contents .. ('%s=%s\n'):format(item.param, tostring(data[item.section][item.param]));
		end
	end
	file:write(contents);
	file:close();
end

return ini_parser;
