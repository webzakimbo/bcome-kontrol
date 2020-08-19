# frozen_string_literal: true

module Bcome::Node
  class Factory
    include Singleton

    attr_reader :estate

    CONFIG_PATH = 'bcome'
    DEFAULT_CONFIG_NAME = 'networks.yml'
    SERVER_OVERRIDE_CONFIG_NAME = 'server-overrides.yml'
    LOCAL_OVERRIDE_CONFIG_NAME = 'me.yml'

    INVENTORY_KEY = 'inventory'
    COLLECTION_KEY = 'collection'
    SUBSELECT_KEY = 'inventory-subselect'
    MERGE_KEY = 'inventory-merge'
    KUBE_CLUSTER = 'kube-cluster'

    BCOME_RC_FILENAME = '.bcomerc'

    def bucket
      @bucket ||= {}
    end

    def init_tree
      @estate = create_node(estate_config)
      @estate
    end

    def config_path
      ENV['CONF'] || "#{CONFIG_PATH}/#{config_file_name}"
    end

    def machines_data_path
      "#{CONFIG_PATH}/#{SERVER_OVERRIDE_CONFIG_NAME}"
    end

    def config_file_name
      @config_file_name || DEFAULT_CONFIG_NAME
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
      conf.flattened
    end

    def create_node(config, parent = nil)
      raise Bcome::Exception::InvalidNetworkConfig, "missing config type for config #{config}" unless config[:type]

      klass = klass_for_view_type[config[:type]]

      raise Bcome::Exception::InvalidNetworkConfig, "invalid config type #{config[:type]}" unless klass

      node = klass.new(views: config, parent: parent)
      create_tree(node, config[:views]) if config[:views]&.any?
      parent.resources << node if parent

      # Load inventory resources as early as possible
      if node.is_a?(Bcome::Node::Inventory::Base)
        node.load_nodes unless node.nodes_loaded?
      end  

      bucket[node.keyed_namespace] = node

      node
    end

    def validate_view(breadcrumb, data)
      raise Bcome::Exception::InvalidNetworkConfig, "Missing namespace type for namespace '#{breadcrumb}'" unless data && data[:type]

      raise Bcome::Exception::InvalidNetworkConfig, "Invalid View Type '#{data[:type]}' for namespace '#{breadcrumb}'. Expecting View Type to be one of: #{klass_for_view_type.keys.join(', ')}" unless is_valid_view_type?(data[:type])
    end

    def klass_for_view_type
      {
        COLLECTION_KEY => ::Bcome::Node::Collection,
        INVENTORY_KEY => ::Bcome::Node::Inventory::Defined,
        SUBSELECT_KEY => ::Bcome::Node::Inventory::Subselect,
        MERGE_KEY => ::Bcome::Node::Inventory::Merge,
        KUBE_CLUSTER => ::Bcome::Node::Kube::Estate
      }
    end

    def is_valid_view_type?(view_type)
      klass_for_view_type.keys.include?(view_type)
    end

    def estate_config
      @estate_config ||= reformat_config(load_estate_config)
    end

    def machines_data
      @machines_data ||= load_machines_data
    end

    def machines_data_for_namespace(namespace)
      machines_data[namespace] || {}
    end

    def load_estate_config
      config = YAML.load_file(config_path).deep_symbolize_keys
      config.deep_merge(local_data)
    rescue ArgumentError, Psych::SyntaxError => e
      raise Bcome::Exception::InvalidNetworkConfig, 'Invalid yaml in network config' + e.message
    rescue Errno::ENOENT
      raise Bcome::Exception::DeprecationWarning if is_running_deprecated_configs?

      raise Bcome::Exception::MissingNetworkConfig, config_path
    end

    def load_machines_data
      return {} unless File.exist?(machines_data_path)

      config = YAML.load_file(machines_data_path).deep_symbolize_keys
      config
    rescue ArgumentError, Psych::SyntaxError => e
      raise Bcome::Exception::InvalidNetworkConfig, 'Invalid yaml in machines data config' + e.message
    end

    def local_data
      @local_data ||= load_local_data
    end

    def local_data_path
      ENV['ME'] || "#{CONFIG_PATH}/#{LOCAL_OVERRIDE_CONFIG_NAME}"
    end

    def load_local_data
      return {} unless File.exist?(local_data_path)

      config = YAML.load_file(local_data_path).deep_symbolize_keys
      return {} if config.nil?

      config
    rescue ArgumentError, Psych::SyntaxError => e
      raise Bcome::Exception::InvalidNetworkConfig, 'Invalid yaml in machines data config' + e.message
    end

    def is_running_deprecated_configs?
      File.exist?('bcome/config/platform.yml')
    end
  end
end
