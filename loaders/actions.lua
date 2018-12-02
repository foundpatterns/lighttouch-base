function get_and_decode_yaml(modulepath)
    local action_yaml = ""
    local line_num = 0
    for line in io.lines(modulepath .. ".lua") do
        line_num = line_num + 1        
        action_yaml = action_yaml .. line .. "\n" -- get only yaml lines
        if line_num == 3 then break end
    end

    return yaml.to_table(action_yaml)
end

function write_yaml_variables(created_file, action_yaml_table)
    created_file:write("local event = { \"" .. action_yaml_table.event[1] .. "\"") -- put values from yaml in lua form
        
    for _, yaml_event in ipairs(action_yaml_table.event) do
        if yaml_event ~= action_yaml_table.event[1] then 
            created_file:write(', "' .. yaml_event .. '"') -- put all events to 'local event = { }'
        end
    end

    created_file:write(" }")
    created_file:write("\nlocal priority = " .. action_yaml_table.priority .. " \n\n")
    if action_yaml_table.input_parameters[1] then
        created_file:write("local input_parameters = { " .. "\"" .. action_yaml_table.input_parameters[1] .. "\"")
        for k, v in pairs(action_yaml_table.input_parameters) do
            if not table.contains(_G.every_events_actions_parameters, v) then table.insert( _G.every_events_actions_parameters, v ) end
            if k ~= 1 then
                created_file:write(", \"" .. v .. "\"")
            end
        end
        created_file:write("}\n") 
    end
end

function write_function(created_file, action_yaml_table, modulepath)
    created_file:write("local function action(arguments)\n") -- function wrapper
                
        for k, v in pairs(action_yaml_table.input_parameters) do
            created_file:write("\n\tlocal " .. v .. " = " .. "arguments[\"" .. v .. "\"]")
        end
        line_num = 0

        for line in io.lines(modulepath .. ".lua") do
            line_num = line_num + 1
            if line_num > 3 then
                created_file:write(line .. "\n\t")
            end
        end
        created_file:write("\nend\n\nreturn{\n\tevent = event,\n\taction = action,\n\tpriority = priority,\n\tinput_parameters = input_parameters\n}") -- ending return
        created_file:close()
end

local default_package_searchers2 = package.searchers[2]
package.searchers[2] = function(name) 
    if string.match( name, "actions") then
        package.preload[name] = function(modulename)
            local created_file = io.open("module.lua", "w+")
            local modulepath = string.gsub(modulename, "%.", "/")
            local path = "/"
            local filename = string.gsub(path, "%?", modulepath)
            local file = io.open(filename, "rb")
            if file then

                local action_yaml_table = get_and_decode_yaml(modulepath) -- decode yaml to lua table
                write_yaml_variables(created_file, action_yaml_table)
                
                write_function(created_file, action_yaml_table, modulepath)
                
                -- Compile and return the module
                local to_compile = io.open("module.lua", "rb")
                return assert(load(assert(to_compile:read("*a")), modulepath))
            end
        end
        return require(name)
    else
        return default_package_searchers2(name)
    end
end

function patched_action(package_name, file_name)
    log.trace("[patching] action " .. ansicolors('%{underline}' .. file_name))
    
    local action_require_name = "packages." .. package_name .. ".actions." .. string.sub( file_name, 0, string.len( file_name ) - 4 )
    
    return require(action_require_name)
end

function assign_action_to_event(action_require, event_name, file_name)
    local event = _G.events[event_name]
    if event then
        table.insert( _G.events_actions[event_name], action_require )
        local action = event:addAction(
            function(action_arguments)
                log.debug("[running] action " .. ansicolors('%{underline}' .. file_name) .. " with priority " .. action_require.priority )
                -- TODO: figure out what to do if more than one responses are returned
                possibleResponse = action_require.action(action_arguments)
                if possibleResponse ~= nil then
                    if possibleResponse.body ~= nil then
                        _G.lighttouch_response = possibleResponse
                        if events["outgoing_response_about_to_be_sent"] then
                            events["outgoing_response_about_to_be_sent"]:trigger({response = possibleResponse})
                        end
                    end
                end
                log.debug("[completed] action " .. ansicolors('%{underline}' .. file_name) )
            end
        )
        event:setActionPriority(action, action_require.priority)
        if isDisabled(file_name) then
            event:disableAction(action)
        end
    else
        log.error("event " .. event_name .. " doesn't exist")
    end
end

function load_actions()
    for k, package_name in pairs (fs.directory_list(_G.packages_path)) do
        local package_path = _G.packages_path .. "/" .. package_name .. "/"
        local actions_path = package_path .. "actions/"
        local action_files = {} -- actions path is optional
        if fs.exists(actions_path) then
            action_files = fs.get_all_files_in(actions_path)
        end
        
        for _, file_name in ipairs(action_files) do
            
            local action_require = patched_action(package_name, file_name)
            
            for k, v in pairs(action_require.event) do
                assign_action_to_event(action_require, v, file_name)
            end 
        end
        
        log.trace("[patched] actions for package " .. ansicolors('%{underline}' .. package_name))
    end
end

load_actions()