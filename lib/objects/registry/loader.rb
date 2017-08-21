module Bcome::Registry
  class Loader

    include ::Singleton

    FILE_PATH = "bcome/registry.yml".freeze

    def data
      @data ||= do_load
    end

    def command_group_for_node(node)
      command_group = ::Bcome::Registry::Command::Group.new(node)

      data.each do |key, commands|
        begin
          if /^#{key.to_s}$/.match(node.namespace) 
            commands.each {|c|
              command_group << ::Bcome::Registry::Command::Base.new_from_raw_command(c) unless restrict_config?(node, c) 
            } 
          end
        rescue RegexpError => e
          raise ::Bcome::Exception::InvalidRegexpMatcherInRegistry.new e.message
        end
      end   
      return command_group
    end

    def restrict_config?(node, command_config)
      return false unless command_config.has_key?(:restrict_to_node)
      node_klass_mapping = restriction_to_node_klass_mappings[command_config[:restrict_to_node].to_sym]
     
      unless node_klass_mapping
        raise Bcome::Exception::InvalidRestrictionKeyInRegistry.new "'#{command_config[:restrict_to_node]}' is invalid. Valid keys: #{restriction_to_node_klass_mappings.keys.join(", ")}"
      end

      return !node.is_a?(node_klass_mapping)
    end

    def restriction_to_node_klass_mappings
      {
        :server => ::Bcome::Node::Server::Base, 
        :inventory => ::Bcome::Node::Inventory,
        :collection => ::Bcome::Node::Collection,
      }
    end

    def do_load
      begin
        file_data = YAML.load_file(FILE_PATH).deep_symbolize_keys
      rescue Psych::SyntaxError => e
        raise ::Bcome::Exception::InvalidRegistryDataConfig.new "Error: #{e.message}"
      end
      return file_data
    end

  end
end
