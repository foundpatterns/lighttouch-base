function actions_loader.set_priority (created_file, header, modulepath)
    created_file:write("\nlocal priority = " .. header.priority .. " \n\n")
end

actions_loader.add_preprocessor(actions_loader.set_priority)