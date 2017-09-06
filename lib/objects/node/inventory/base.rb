module Bcome::Node::Inventory
  class Base < ::Bcome::Node::Base
    def initialize(*params)
      super
      raise Bcome::Exception::InventoriesCannotHaveSubViews, @views if @views[:views] && !@views[:views].empty?
    end

    def meta_matches(matchers)
      data_wrapper = :metadata
      matches_for(data_wrapper, matchers)
    end

    def cloud_matches(matchers)
      data_wrapper = :cloud_tags
      matches_for(data_wrapper, matchers)
    end

    def machine_by_identifier(identifier)
      resources.active.select { |machine| machine.identifier == identifier }.first
    end

    def matches_for(data_wrapper, matchers)
      resources.active.select do |machine|
        machine.send(data_wrapper).has_key_and_value?(matchers)
      end
    end

    def enabled_menu_items
      super + %i[ssh]
    end

    def menu_items
      base_items = super.dup
      base_items[:ssh] = {
        description: 'ssh directly into a resource',
        usage: 'ssh identifier',
        console_only: true
      }
      base_items
    end

    def resources
      @resources ||= ::Bcome::Node::Resources::Inventory.new
    end

    def ssh(identifier = nil)
      direct_invoke_server(:ssh, identifier)
    end

    def tags(identifier = nil)
      direct_invoke_server(:tags, identifier)
    end

    def direct_invoke_server(method, identifier)
      unless identifier
        puts "\nPlease provide a machine identifier, e.g. #{method} machinename\n".warning unless identifier
        return
      end

      if resource = resources.for_identifier(identifier)
        resource.send(method)
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

    def reload
      do_reload
      puts "\nDone. Hit 'ls' to see the refreshed inventory.\n".informational
    end

    def inventory?
      true
    end

    def override_server_identifier?
      !@override_identifier.nil?
    end
  end
end
