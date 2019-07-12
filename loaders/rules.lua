rules_loader = { 
  preprocessors = {}
}

require("loaders.rules.mod")

default_package_searchers2_rules = package.searchers[2]
package.searchers[2] = rules_loader.custom_require

each(fs.directory_list(_G.packages_path), rules_loader.create_rules)

return rules_loader
