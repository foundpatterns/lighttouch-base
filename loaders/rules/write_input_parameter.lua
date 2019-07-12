function rules_loader.write_input_parameter (created_file, header, modulename, priority, modulepath)
  created_file:write("\nlocal input_parameter = \"" .. header.input_parameter .. "\"")
end

rules_loader.add_preprocessor(rules_loader.write_input_parameter)