module Bcome::Node::Inventory
  class Defined < ::Bcome::Node::Inventory::Base
    MACHINES_CACHE_PATH = 'machines-cache.yml'.freeze

    def self.to_s
      'inventory'
    end

    attr_reader :dynamic_nodes_loaded

    def initialize(*params)
      @load_machines_from_cache = false
      @cache_handler = ::Bcome::Node::CacheHandler.new(self)
      super
    end

    def enabled_menu_items
      super + %i[save reload]
    end

    def menu_items
      base_items = super.dup

      base_items[:reload] = {
        description: "Restock this inventory from remote (hit 'save' after to persist)",
        console_only: true
      }
      base_items
    end

    def reload
      resources.reset_duplicate_nodes!
      do_reload
      puts "\nDone. Hit 'ls' to see the refreshed inventory.\n".informational
    end

    def set_static_servers
      if raw_static_machines_from_cache
        raw_static_machines_from_cache.each do |server_config|
          resources << ::Bcome::Node::Server::Static.new(views: server_config, parent: self)
        end
      end
    end

    def raw_static_machines_from_cache
      load_machines_config[namespace.to_sym]
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
                                                  :capture_input, terminal_prompt: "\nAre you sure you want to cache these machines (saving will overwrite any previous selections) [Y|N] ? ")

      if @answer && @answer == 'Y'
        cache_nodes_in_memory
        data = load_machines_config
        data[namespace] = views[:static_servers]

        File.open(machines_cache_path, 'w') do |file|
          file.write data.to_yaml
        end
        mark_as_cached!
        puts "Machines have been cached for node #{namespace}".informational
      else
        puts 'Nothing saved'.warning
      end
    end

    def load_machines_config
      config = YAML.load_file(machines_cache_path).deep_symbolize_keys
      return config
    rescue ArgumentError, Psych::SyntaxError
      raise Bcome::Exception::InvalidMachinesCacheConfig, 'Invalid yaml in config'
    rescue Errno::ENOENT
      return {}
    end

    def cache_nodes_in_memory
      @cache_handler.do_cache_nodes!
    end

    def do_reload
      resources.unset!
      load_dynamic_nodes
    end

    def load_nodes
      set_static_servers
      load_dynamic_nodes unless @load_machines_from_cache
    end

    def load_dynamic_nodes
      raw_servers = fetch_server_list

      raw_servers.each do |raw_server|
        if raw_server.is_a?(Google::Apis::ComputeBeta::Instance)
          resourcs << ::Bcome::Node::Server::Dynamic.new_from_gcp_instance(raw_server, self)
        elsif raw_server.is_a?(Fog::Compute::AWS::Server)
          resources << ::Bcome::Node::Server::Dynamic.new_from_fog_instance(raw_server, self)
        else
          Bcome::Exception::UnknownDynamicServerType, 'Unknown dynamic server type' 
        end
      end

      resources.rename_initial_duplicate if resources.should_rename_initial_duplicate?

    end

    def fetch_server_list
      return [] unless network_driver
      network_driver.fetch_server_list(filters)
    end
  end
end
