function rules_loader.write_return (created_file, header, modulename, priority, modulepath)
  created_file:write("\nreturn{\n\trule = rule,\n\tpriority = priority,\n\tget_events_parameters = get_events_parameters\n}")
end

rules_loader.add_preprocessor(rules_loader.write_return)