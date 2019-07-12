function actions_loader.write_function (created_file, header, modulepath)
    created_file:write("local function action(arguments)\n") -- function wrapper
    for k, v in pairs(header.input_parameters) do
      created_file:write("\n\tlocal " .. v .. " = " .. "arguments[\"" .. v .. "\"]")
    end
    line_num = 0
    for line in io.lines(modulepath .. ".lua") do
      line_num = line_num + 1
      if line_num > 3 then
        created_file:write(line .. "\n\t")
      end
    end
    created_file:write("\nend")
end

actions_loader.add_preprocessor(actions_loader.write_function)