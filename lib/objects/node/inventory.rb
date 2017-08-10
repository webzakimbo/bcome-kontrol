module Bcome::Node
  class Inventory < ::Bcome::Node::Base

    def self.to_s
      'inventory'
    end

    attr_reader :dynamic_nodes_loaded

    def initialize(*params)
      @load_from_cache = false
      @cache_handler = ::Bcome::Node::CacheHandler.new(self)
      super
      raise Bcome::Exception::InventoriesCannotHaveSubViews, @views if @views[:views] && !@views[:views].empty?
    end

    def meta_matches(matchers)
      data_wrapper = :metadata
      return matches_for(data_wrapper, matchers)
    end

    def cloud_matches(matchers)
      data_wrapper = :cloud_tags
      matches_for(data_wrapper, matchers)
    end

    def matches_for(data_wrapper, matchers)
      resources.active.select{|machine|
        machine.send(data_wrapper).has_key_and_value?(matchers)
      }
    end

    def enabled_menu_items
      super + [:save, :ssh]
    end

    def menu_items
      base_items = super.dup
      base_items[:ssh] = {
        description: "ssh directly into a resource",
        usage: "ssh identifier",
        console_only: true
      }
      base_items
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

    def save
      cache_nodes_in_memory
      ::Bcome::Node::Factory.instance.save_cache!
    end

    def ssh(identifier)
      if resource = resources.for_identifier(identifier)
        resource.send(:ssh)
      else
        raise Bcome::Exception::InvalidBreadcrumb, "Cannot find a node named '#{identifier}'"
      end
    end

    def cache_nodes_in_memory
      @cache_handler.do_cache_nodes!
      puts "processing #{self.namespace}".informational
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
      puts "\nDone. Hit 'ls' to see the refreshed inventory.\n".informational
    end

    def override_server_identifier?
      !@override_identifier.nil?
    end

    def load_nodes
      set_static_servers
      unless @load_from_cache
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
