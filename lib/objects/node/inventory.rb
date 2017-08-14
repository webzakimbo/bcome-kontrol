module Bcome::Node
  class Inventory < ::Bcome::Node::Base

    MACHINES_CACHE_PATH = 'machines-cache.yml'.freeze

    def self.to_s
      'inventory'
    end

    attr_reader :dynamic_nodes_loaded

    def initialize(*params)
      @load_machines_from_cache = false
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
      if raw_static_machines_from_cache
        raw_static_machines_from_cache.each {|server_config|
          resources << ::Bcome::Node::Server::Static.new(views: server_config, parent: self)
        }
      end
    end

    def raw_static_machines_from_cache
      return load_machines_config[namespace.to_sym]
    end

    def resources
      @resources ||= ::Bcome::Node::Resources::Inventory.new
    end

    def machines_cache_path
      "#{::Bcome::Node::Factory::CONFIG_PATH}/#{MACHINES_CACHE_PATH}"
    end

    def mark_as_cached!
      data = ::Bcome::Node::Factory.instance.load_estate_config
      data[namespace.to_sym][:load_machines_from_cache] = true
      ::Bcome::Node::Factory.instance.rewrite_estate_config(data)
    end 

    def save
      @answer = ::Bcome::Interactive::Session.run(self,
        :capture_input, { terminal_prompt: "Are you sure you want to cache these machines (saving will overwrite any previous selections) [Y|N] ? " }
      )

      if @answer && @answer == "Y"
        cache_nodes_in_memory
        data = load_machines_config
        data[namespace] = views[:static_servers]

        File.open(machines_cache_path,"w") do |file|
          file.write data.to_yaml
        end
        mark_as_cached!
        puts "Machines have been cached for node #{namespace}".informational
      else
        puts "Nothing saved".warning
      end
    end

    def load_machines_config
      begin
        config = YAML.load_file(machines_cache_path).deep_symbolize_keys
        return config
      rescue ArgumentError, Psych::SyntaxError
        raise Bcome::Exception::InvalidMachinesCacheConfig, 'Invalid yaml in config'
      rescue Errno::ENOENT  
        return {}
      end
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
      unless @load_machines_from_cache
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
