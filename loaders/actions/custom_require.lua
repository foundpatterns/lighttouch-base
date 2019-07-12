function actions_loader.custom_require(name)
    if string.match( name, "actions") then
      package.preload[name] = function(modulename)
	local created_file = io.open("module.lua", "w+")
	local modulepath = _G.cwd .. string.gsub(modulename, "%.", "/")
        local path = "/"
        local filename = string.gsub(path, "%?", modulepath)
        local file = io.open(filename, "rb")
        if file then
          local header = actions_loader.extract_header(modulepath)

          for _, fn in ipairs(actions_loader.preprocessors) do
            fn(created_file, header, modulepath)
          end
  
          created_file:close()
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
