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
        if node.namespace =~ /^#{key.to_s}/ 
          commands.each {|c| command_group << ::Bcome::Registry::Command::Base.new_from_raw_command(c) }
        end
      end   
      return command_group
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
