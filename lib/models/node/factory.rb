module Bcome::Node
  class Factory

    include Singleton

    attr_reader :estate

    CONFIG_PATH = 'config/bcome/estate.yml'.freeze
    INVENTORY_KEY = 'inventory'.freeze
    COLLECTION_KEY = 'collection'.freeze
    BCOME_RC_FILENAME = '.bcomerc'.freeze

    def init_tree
      @estate = create_node(estate_config)
      return @estate
    end

    def config_path
      CONFIG_PATH
    end

    def create_tree(context_node, views)
      views.each { |config| create_node(config, context_node) }
    end

    def create_node(config, parent = nil)
      validate_views(config)
      klass = klass_for_view_type[config[:type]]
      node = klass.new(views: config, parent: parent)
      create_tree(node, config[:views]) if config[:views] && config[:views].any?
      parent.resources << node if parent
      node
    end

    def save_cache!
      config = estate.rewrite_estate_config      
      File.open(config_path,"w") do |file|
        file.write config.to_yaml
      end
      puts "\nNetwork configuration saved to #{config_path}".bc_yellow
    end

    def estate_config
      @estate_config ||= load_estate_config
    end

    def load_estate_config
      begin
        config = YAML.load_file(config_path).deep_symbolize_keys
        return config
      rescue ArgumentError
        raise Bcome::Exception::InvalidEstateConfig, 'Invalid yaml in config'
      rescue Errno::ENOENT
        raise Bcome::Exception::MissingEstateConfig, config_path
      end
    end

    def validate_views(config)
      raise Bcome::Exception::InvalidEstateConfig, "Invalid view type for (#{config.inspect})" unless is_valid_view_type?(config[:type])
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
   
  end
end
