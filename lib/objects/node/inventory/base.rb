# frozen_string_literal: true

module Bcome
  module Node
    module Inventory
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
          super + %i[ssh tags]
        end

        def menu_items
          base_items = super.dup
          base_items[:ssh] = {
            description: 'ssh directly into a resource',
            usage: 'ssh identifier',
            console_only: true
          }

          base_items[:tags] = {
           description: 'print out server tags/labels'
          }

          base_items
        end

        def resources
          @resources ||= ::Bcome::Node::Resources::Inventory.new(self)
        end

        def ssh(identifier = nil)
          direct_invoke_server(:ssh, identifier)
        end

        def tags(identifier = nil)
          identifier.nil? ? direct_invoke_all_servers(:tags) : direct_invoke_server(:tags, identifier)
        end

        def direct_invoke_server(method, identifier)
          # If we only have a single resource in our inventory, then just allow direct invocation
          if resources.size == 1
            resource = resources.first
          else
            # Otherwise, we expect to find the resource by its identifier
            unless identifier
              puts "\nPlease provide a machine identifier, e.g. #{method} machinename\n".warning unless identifier
              return
            end

            resource = resources.for_identifier(identifier)
            raise Bcome::Exception::InvalidBreadcrumb, "Cannot find a node named '#{identifier}'" unless resource
          end

          resource.send(method)
        end

        def direct_invoke_all_servers(method)
          resources.active.each { |m| m.send(method) }
          nil
        end

        def cache_nodes_in_memory
          @cache_handler.do_cache_nodes!
        end

        def list_key
          :server
        end

        def machines(skip_for_hidden = true)
          skip_for_hidden ? resources.active : resources.active.reject(&:hide?)
        end

        def inventory?
          true
        end

        def override_server_identifier?
          respond_to?(:override_identifier) && !override_identifier.nil?
        end
      end
    end
  end
end
