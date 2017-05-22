module Bcome::Node::Factory
  CONFIG_PATH = 'config/bcome/estate.yml'.freeze
  DYNAMIC_INVENTORY_KEY = 'dynamic_inventory'.freeze
  COLLECTION_KEY = 'collection'.freeze
  BCOME_RC_FILENAME = '.bcomerc'.freeze

  class << self
    def init_tree
      create_node(load_estate_config)
    end

    def create_tree(context_node, views)
      views.each { |config| create_node(config, context_node) }
    end

    def create_node(config, parent = nil)
      validate_view_data(config)
      klass = klass_for_view_type[config[:type]]
      node = klass.new(view_data: config, parent: parent)
      create_tree(node, config[:views]) if config[:views] && config[:views].any?
      parent.resources << node if parent
      node
    end

    def load_estate_config
      config = YAML.load_file(CONFIG_PATH).deep_symbolize_keys
      return config
    rescue ArgumentError
      raise Bcome::Exception::InvalidEstateConfig, 'Invalid yaml in config'
    rescue Errno::ENOENT
      raise Bcome::Exception::MissingEstateConfig, CONFIG_PATH
    end

    def validate_view_data(config)
      raise Bcome::Exception::InvalidEstateConfig, "Invalid view type for (#{config.inspect})" unless is_valid_view_type?(config[:type])
    end

    #    def has_local_bcome_rc?
    #      File.exist?(BCOME_RC_FILENAME)
    #    end

    #    def user_local_config
    #      return has_local_bcome_rc? ? load_bcome_rc : {}
    #    end

    #    def load_bcome_rc
    #      config = YAML.load_file(BCOME_RC_FILENAME).deep_symbolize_keys
    #      return config
    #    end

    def klass_for_view_type
      {
        COLLECTION_KEY => ::Bcome::Node::Collection,
        DYNAMIC_INVENTORY_KEY => ::Bcome::Node::Inventory::Dynamic
      }
    end

    def is_valid_view_type?(view_type)
      klass_for_view_type.keys.include?(view_type)
    end
  end
end
