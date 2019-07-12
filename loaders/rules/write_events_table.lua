function rules_loader.write_events_table (created_file, header, modulename, priority, modulepath)
  created_file:write("\nlocal events_table = { " .. "\"" .. header.events_table[1] .. "\"")
  for k, v in pairs(header.events_table) do
    if k ~= 1 then
      created_file:write(", " .. "\"" .. v .. "\"")
    end
  end
  created_file:write("}")
end

rules_loader.add_preprocessor(rules_loader.write_events_table)