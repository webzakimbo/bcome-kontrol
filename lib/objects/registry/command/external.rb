module Bcome::Registry::Command
  class External < Base

    # In which the bcome context is passed to an external call

    def execute(node, arguments)
      # arguments   raise if substitution and no default value set
      # local_command
      process_arguments(arguments)
    end

    def local_command_substitutions
      local_command.scan(/%\d+%/).uniq
    end

    def expected_keys
      super + [:local_command]
    end

    def do_pretty_print
      menu_str = super + "\n\s\s\s\slocal command:\s".resource_key + local_command.resource_value
      menu_str += "\n\s\s\s\sdefaults:\s".resource_key + defaults.inspect.resource_value
      return menu_str + "\n\n"
    end

  end
end
