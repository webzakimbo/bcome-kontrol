module Bcome::Node
  class Factory

    include Singleton

    attr_reader :estate

    CONFIG_PATH = 'bcome'.freeze
    DEFAULT_CONFIG_NAME = 'networks.yml'.freeze
    INVENTORY_KEY = 'inventory'.freeze
    COLLECTION_KEY = 'collection'.freeze
    BCOME_RC_FILENAME = '.bcomerc'.freeze

    def init_tree
      @estate = create_node(estate_config)
      return @estate
    end

    def config_path
      "#{CONFIG_PATH}/#{config_file_name}"
    end

    def config_file_name
      @config_file_name ||= ENV["CONF"] ? ENV["CONF"] : DEFAULT_CONFIG_NAME
    end

    def create_tree(context_node, views)
      views.each { |config| create_node(config, context_node) }
    end

    def reformat_config(config)
      conf = ::Bcome::ConfigFactory.new
      config.each do |crumb, data|
        validate_view(crumb, data)
        crumbs = Bcome::Parser::BreadCrumb.parse(crumb)
        conf.add_crumbs(crumbs, data)
      end
      return conf.flattened
    end

    def create_node(config, parent = nil)
      klass = klass_for_view_type[config[:type]]
      node = klass.new(views: config, parent: parent)
      create_tree(node, config[:views]) if config[:views] && config[:views].any?
      parent.resources << node if parent
      node
    end

    def save_cache!
      config = estate.rewrite_estate_config      

      @config_file_name = ::Bcome::Interactive::Session.run(self,
        :capture_input, { current_filename: config_file_name, start_message: "Select to which file you'd like to save your new network manifest" }
      )

      if @config_file_name
        File.open(config_path,"w") do |file|
          file.write config.to_yaml
        end
        puts "\nNetwork configuration saved to #{config_path}".informational
      end
    end

    def validate_view(breadcrumb, data)
      unless data[:type]
        raise Bcome::Exception::InvalidNetworkConfig, "Missing view type for for namespace '#{breadcrumb}'"
      end

      unless is_valid_view_type?(data[:type])
        raise Bcome::Exception::InvalidNetworkConfig, "Invalid View Type '#{data[:type]}' for namespace '#{breadcrumb}'. Expecting View Type to be one of: #{klass_for_view_type.keys.join(", ")}" 
      end

    end

    def klass_for_view_type
      {
        COLLECTION_KEY => ::Bcome::Node::Collection,
        INVENTORY_KEY => ::Bcome::Node::Inventory,
      }
    end

    def is_valid_view_type?(view_type)
      klass_for_view_type.keys.include?(view_type)
    end

    def estate_config
      @estate_config ||= load_estate_config
    end

    def load_estate_config
      begin
        config = YAML.load_file(config_path).deep_symbolize_keys
        reformatted_config = reformat_config(config)
        return reformatted_config
      rescue ArgumentError, Psych::SyntaxError
        raise Bcome::Exception::InvalidNetworkConfig, 'Invalid yaml in config'
      rescue Errno::ENOENT
        raise Bcome::Exception::MissingNetworkConfig, config_path
      end
    end

  end
end
