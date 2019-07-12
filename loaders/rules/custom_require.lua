function rules_loader.custom_require(name)
  if string.match( name, "rules") then
    package.preload[name] = function(modulename)
      local created_file = io.open("module.lua", "w+")
      local modulepath = _G.cwd .. string.gsub(modulename, "%.", "/")
      local path = "/"
      local filename = string.gsub(path, "%?", modulepath)
      local file = io.open(filename, "rb")
      if file then
        local header = rules_loader.extract_header(modulepath)
        local priority = header.priority or 1

        -- rules_loader.write_priority(created_file, header, modulename, priority, modulepath)
        -- rules_loader.write_events_table(created_file, header, modulename, priority, modulepath)
        -- rules_loader.write_input_parameter(created_file, header, modulename, priority, modulepath)
        -- rules_loader.write_rule_function(created_file, header, modulename, priority, modulepath)
        -- rules_loader.write_get_events_parameters(created_file, header, modulename, priority, modulepath)
        -- rules_loader.write_return(created_file, header, modulename, priority, modulepath)

        for _, fn in ipairs(rules_loader.preprocessors) do
          fn(created_file, header, modulename, priority, modulepath)
        end

        created_file:close()
        local to_compile = io.open("module.lua", "rb")
        return assert(load(assert(to_compile:read("*a")), modulepath))
      end
    end
    return require(name)
  else
    return default_package_searchers2_rules(name)
  end
end
