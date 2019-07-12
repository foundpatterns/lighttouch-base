function rules_loader.write_rule_function (created_file, header, modulename, priority, modulepath)
  created_file:write("\nlocal events_parameters = { }")
  created_file:write("\nlocal function rule(" .. header.input_parameter)
    for k, v in pairs (_G.every_events_actions_parameters) do
      if v ~= header.input_parameter then
        created_file:write(", " .. v)
      end
    end
    created_file:write(")")

    created_file:write("\n\tlog.trace('[evaluating] " .. _G.ansicolors('%{underline}' .. modulename) .. " with priority " .. priority .. " starting to evaluate')")

    created_file:write("\n\tlocal arguments_strings_dictionary = { }")
    created_file:write("\n\targuments_strings_dictionary[\"" .. header.input_parameter .. "\"] = " .. header.input_parameter)
    for k, v in pairs (_G.every_events_actions_parameters) do -- matching rule arguments with action required parameters, so events_parameters["p1"] = p1
      if v ~= header.input_parameter then
        created_file:write("\n\targuments_strings_dictionary[\"" .. v .. "\"] = " .. v)
      end
    end

    created_file:write("\n\tfor k, v in pairs(events_parameters) do")
      created_file:write("\n\t\tevents_parameters[k] = arguments_strings_dictionary[k]")
    created_file:write("\n\tend")
    created_file:write("\n\tif")
    line_num = 0
    for line in io.lines(modulepath .. ".lua") do
      line_num = line_num + 1
      if line_num > 3 then
        created_file:write("\n\t" .. line)
      end
    end
    created_file:write("\n\tthen")
      created_file:write("\n\t\tlog.trace(\"Rule " .. _G.ansicolors('%{underline}' .. modulename) .. " evaluated as TRUE \")")

      created_file:write("\n\t\tfor k, v in pairs(events_table) do")
        created_file:write("\n\t\t\tevents[v]:trigger(events_parameters)")
      created_file:write("\n\t\tend")
    created_file:write("\n\telse")
      created_file:write("\n\t\tlog.trace(\"Rule " .. _G.ansicolors('%{underline}' .. modulename) .. " evaluated as FALSE \")")
    created_file:write("\n\tend")
  created_file:write("\nend\n") -- bottom rule function wrapper
end

rules_loader.add_preprocessor(rules_loader.write_rule_function)