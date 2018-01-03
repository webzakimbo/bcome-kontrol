module Bcome::Registry
  class Loader
    include ::Singleton

    FILE_PATH = 'bcome/registry.yml'.freeze

    def data
      @data ||= do_load
    end

    def set_command_group_for_node(node)
      if group_for_node = ::Bcome::Registry::CommandList.instance.group_for_node(node)
        return group_for_node
      end

      command_group = init_new_command_group(node)

      data.each do |key, commands|
        begin
          if /^#{key.to_s}$/.match(node.keyed_namespace)
            commands.each do |c|

              unless c[:console_command]
                error_message = "Registry method is missing key 'console_command'."
                error_message += "\n\n#{c.inspect}"
                raise Bcome::Exception::InvalidRegistryDataConfig.new error_message
              end

              # Verify that the proposed user registered method does not conflict with either an existing method name, instance var, or other registry command name for this node
              if node.is_node_level_method?(c[:console_command]) || command_group.console_method_name_exists?(c[:console_command])
                raise Bcome::Exception::MethodNameConflictInRegistry, "'#{c[:console_command]}'"
              end
              command_group << ::Bcome::Registry::Command::Base.new_from_raw_command(c) unless restrict_config?(node, c)
              ::Bcome::Registry::CommandList.instance.register(node, c[:console_command].to_sym)
            end
          end
        rescue RegexpError => e
          raise Bcome::Exception::InvalidRegexpMatcherInRegistry, e.message
        end
      end
      ::Bcome::Registry::CommandList.instance.add_group_for_node(node, command_group)
    end

    def init_new_command_group(node)
      ::Bcome::Registry::Command::Group.new(node)
    end

    def restrict_config?(node, command_config)
      return false unless command_config.key?(:restrict_to_node)
      node_klass_mapping = restriction_to_node_klass_mappings[command_config[:restrict_to_node].to_sym]

      unless node_klass_mapping
        raise Bcome::Exception::InvalidRestrictionKeyInRegistry, "'#{command_config[:restrict_to_node]}' is invalid. Valid keys: #{restriction_to_node_klass_mappings.keys.join(', ')}"
      end

      !node.is_a?(node_klass_mapping)
    end

    def restriction_to_node_klass_mappings
      {
        server: ::Bcome::Node::Server::Base,
        inventory: ::Bcome::Node::Inventory,
        collection: ::Bcome::Node::Collection
      }
    end

    def do_load
      return {} unless File.exist?(FILE_PATH)
      begin
        file_data = YAML.load_file(FILE_PATH).deep_symbolize_keys
      rescue Psych::SyntaxError => e
        raise Bcome::Exception::InvalidRegistryDataConfig, "Error: #{e.message}"
      end
      file_data
    end
  end
end
