module Bcome::Registry::Command
  class External < Base
    # In which the bcome context is passed to an external call

    def execute(node, arguments)
      full_command = construct_full_command(node, arguments)
      begin
        puts "\n(external) > #{full_command}".bc_blue + "\n\n"
        system(full_command)
      rescue Interrupt
        puts "\nExiting gracefully from interrupt\n".warning
      end
    end

    def construct_full_command(node, arguments)
      substituted_command = construct_substituted_command(arguments)
      namespaced_command = namespace_command(node, substituted_command)
      namespaced_command
    end

    def construct_substituted_command(arguments)
      substituted_command = local_command
      merged_arguments = process_arguments(arguments)

      local_command_substitutions.each do |substitution|
        substitute_with = merged_arguments[substitution.to_sym]
        unless substitute_with
          error_message_suffix = "- missing '#{substitution}' from command '#{local_command}'"
          raise Bcome::Exception::MissingArgumentForRegistryCommand, error_message_suffix
        end

        substituted_command.gsub!("%#{substitution}%", substitute_with)
      end
      substituted_command
    end

    def namespace_command(node, command)
      "#{command} bcome_context=\"#{node.keyed_namespace}\""
    end

    def local_command_substitutions
      local_command.scan(/%(.+)%/).uniq.flatten
    end

    def expected_keys
      super + [:local_command]
    end

    def do_pretty_print
      menu_str = super + "\n\s\s\s\slocal command:\s".resource_key + local_command.resource_value
      menu_str += "\n\s\s\s\sdefaults:\s".resource_key + defaults.inspect.resource_value
      menu_str + "\n\n"
    end
  end
end
