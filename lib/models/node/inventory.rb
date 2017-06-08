module Bcome::Node
  class Inventory < ::Bcome::Node::Base

    def self.to_s
      'inventory'
    end

    attr_reader :dynamic_nodes_loaded

    def initialize(*params)
      @read_from_cache_only = false
      @cache_handler = ::Bcome::Node::CacheHandler.new(self)
      super
      raise Bcome::Exception::InventoriesCannotHaveSubViews, @views if @views[:views] && !@views[:views].empty?
    end

    def set_static_servers
      if server_configs = @views[:static_servers]
        server_configs.each {|server_config|
          resources << ::Bcome::Node::Server::Static.new(views: server_config, parent: self)
        }
      end
    end

    def resources
      @resources ||= ::Bcome::Node::Resources::Inventory.new
    end

    def rewrite_estate_config
      views
    end

    def cache!
      cache_nodes_in_memory
      ::Bcome::Node::Factory.instance.save_cache!
    end

    def cache_nodes_in_memory
      @cache_handler.do_cache_nodes!
      puts "processing #{self.namespace}".bc_orange
    end

    def list_key
      :server
    end

    def machines
      @resources.active
    end

    def reload!
      resources.unset!
      load_dynamic_nodes
      puts "\nDone. Hit 'ls' to see the refreshed inventory.\n".bc_green
    end

    def override_server_identifier?
      !@override_identifier.nil?
    end

    def load_nodes
      set_static_servers
      unless @read_from_cache_only
        load_dynamic_nodes 
      end
    end

    def load_dynamic_nodes
      raw_servers = fetch_server_list
      raw_servers.each do |raw_server|
        resources << ::Bcome::Node::Server::Dynamic.new_from_fog_instance(raw_server, self)
      end
    end

    def fetch_server_list
      return [] unless network_driver
      network_driver.fetch_server_list(filters)
    end
  end
end
