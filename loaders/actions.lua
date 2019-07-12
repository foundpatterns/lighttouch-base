actions_loader = { 
  preprocessors = {}
}

require("loaders.actions.mod")

default_package_searchers2 = package.searchers[2]
package.searchers[2] = actions_loader.custom_require
-- actions requiring
-- runs the function against all packages in packages_path
each(fs.directory_list(_G.packages_path), actions_loader.create_actions)

return actions_loader
