function rules_loader.write_priority (created_file, header, modulename, priority, modulepath)
  if priority > 100 then priority = 100 end

  created_file:write("local priority = " .. priority)
end

rules_loader.add_preprocessor(rules_loader.write_priority)