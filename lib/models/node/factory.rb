module Bcome::Node
  class Factory

    include Singleton

    CONFIG_PATH = 'config/bcome/estate.yml'.freeze
    INVENTORY_KEY = 'inventory'.freeze
    COLLECTION_KEY = 'collection'.freeze
    BCOME_RC_FILENAME = '.bcomerc'.freeze

    def init_tree
      create_node(estate_config)
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

    def estate_config
      @estate_config ||= load_estate_config
    end

    def load_estate_config
      begin
        config = YAML.load_file(CONFIG_PATH).deep_symbolize_keys
        return config
      rescue ArgumentError
        raise Bcome::Exception::InvalidEstateConfig, 'Invalid yaml in config'
      rescue Errno::ENOENT
        raise Bcome::Exception::MissingEstateConfig, CONFIG_PATH
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
