# frozen_string_literal: true

module Bcome
  module Node
    module Inventory
      class Merge < ::Bcome::Node::Inventory::Base

        def self.to_s
          'merged inventory'
        end

        attr_reader :dynamic_nodes_loaded

        def initialize(*params)
          super
          raise Bcome::Exception::MissingInventoryContributors, @views unless @views[:contributors]
        end

        def nodes_loaded?
          true
        end

        def contributing_inventories
          @inventories ||= @views[:contributors].collect{|inventory_key| load_inventory(inventory_key)}
        end

        def resources
          @resources ||= do_set_resources
        end

        def update_nodes
          resources.update_nodes(self)
        end

        def do_set_resources
          ::Bcome::Node::Resources::Merged.new(inventory: self)
        end

        def load_inventory(from_crumb)
          inventory = ::Bcome::Node::Factory.instance.bucket[from_crumb]
          raise Bcome::Exception::CannotFindInventory, "for key '#{from_crumb}'" unless inventory
          inventory
        end

      end
    end
  end
end
