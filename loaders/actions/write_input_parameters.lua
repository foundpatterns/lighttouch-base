function actions_loader.write_input_parameters (created_file, header, modulepath)
    if header.input_parameters[1] then
      created_file:write("local input_parameters = { " .. "\"" .. header.input_parameters[1] .. "\"")
      for k, v in pairs(header.input_parameters) do
        if not table.contains(_G.every_events_actions_parameters, v) then table.insert( _G.every_events_actions_parameters, v ) end
        if k ~= 1 then
          created_file:write(", \"" .. v .. "\"")
        end
      end
      created_file:write("}\n")
    end
end

actions_loader.add_preprocessor(actions_loader.write_input_parameters)