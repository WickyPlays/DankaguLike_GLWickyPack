local ini_parser = {};

-- Load function to parse INI files
function ini_parser.load(fileName)
    -- Validate the input parameter
    assert(type(fileName) == 'string', 'File name must be a string.');

    -- Try to open the file
    local file = assert(io.open(fileName, 'r'), 'Error loading file: ' .. fileName);
    local parsed_data = { __order = {} };
    local current_section = nil;

    -- Iterate through each line of the file
    for line in file:lines() do
        -- Handle empty lines
        if line:match('^%s*$') then
            table.insert(parsed_data.__order, { type = "empty" });

        -- Handle comments
        elseif line:match('^;%s*(.*)$') then
            local comment_text = line:match('^;%s*(.*)$');
            table.insert(parsed_data.__order, { type = "comment", comment = comment_text, section = current_section });

        -- Handle sections
        elseif line:match('^%[([^%[%]]+)%]$') then
            local section_name = line:match('^%[([^%[%]]+)%]$');
            current_section = tonumber(section_name) or section_name;

            if not parsed_data[current_section] then
                parsed_data[current_section] = { __order = {} };
                table.insert(parsed_data.__order, { type = "section", section = current_section });
            end

        -- Handle key-value pairs
        elseif line:match('^([%w|_]+)%s-=%s-(.+)$') then
            local key, value = line:match('^([%w|_]+)%s-=%s-(.+)$');

            -- Convert value to the appropriate type
            if tonumber(value) then
                value = tonumber(value);
            elseif value == 'true' then
                value = true;
            elseif value == 'false' then
                value = false;
            end

            -- Convert key to number if applicable
            if tonumber(key) then
                key = tonumber(key);
            end

            parsed_data[current_section][key] = value;
            table.insert(parsed_data[current_section].__order, key);
            table.insert(parsed_data.__order, { type = "pair", section = current_section, param = key, value = value });
        end
    end

    -- Close the file
    file:close();
    return parsed_data;
end

-- Save function to write data back to an INI file
function ini_parser.save(fileName, data)
    -- Validate input parameters
    assert(type(fileName) == 'string', 'File name must be a string.');
    assert(type(data) == 'table', 'Parameter "data" must be a table.');

    -- Try to open the file for writing
    local file = assert(io.open(fileName, 'w+b'), 'Error loading file: ' .. fileName);
    local file_contents = '';
    local order = data.__order or {};

    -- Iterate through the order to construct the file contents
    for _, item in ipairs(order) do
        if item.type == "empty" then
            file_contents = file_contents .. '\n';
        elseif item.type == "comment" then
            file_contents = file_contents .. ('; %s\n'):format(item.comment);
        elseif item.type == "section" then
            file_contents = file_contents .. ('[%s]\n'):format(item.section);
        elseif item.type == "pair" then
            file_contents = file_contents .. ('%s=%s\n'):format(item.param, tostring(data[item.section][item.param]));
        end
    end

    -- Write the contents to the file and close it
    file:write(file_contents);
    file:close();
end

-- Return the parser module
return ini_parser;
