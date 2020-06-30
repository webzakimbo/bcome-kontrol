# frozen_string_literal: true

module Bcome
  module Node
    module Inventory
      class Subselect < ::Bcome::Node::Inventory::Base
        def initialize(*params)
          super
          raise Bcome::Exception::MissingSubselectionKey, @views unless @views[:subselect_from]

          update_nodes
        end

        def enabled_menu_items
          super + %i[reload]
        end

        def menu_items
          base_items = super.dup

          base_items[:reload] = {
            description: 'Restock this inventory from remote',
            console_only: true,
            group: :miscellany
          }
          base_items
        end

        def resources
          @resources ||= do_set_resources
        end

        def update_nodes
          resources.update_nodes(self)
        end

        def do_set_resources
          ::Bcome::Node::Resources::SubselectInventory.new(parent_inventory: parent_inventory, filters: filters)
        end

        def nodes_loaded?
          true
        end

        def filters
          @views[:sub_filter] || @views[:filters] || {}
        end

        def reload
          do_reload
        end

        def do_reload
          parent_inventory.resources.reset_duplicate_nodes!
          parent_inventory.do_reload
          resources.run_subselect
          update_nodes
          nil
        end

        private

        def parent_inventory
          @parent_inventory ||= load_parent_inventory
        end

        def load_parent_inventory
          raise ::Bcome::Exception::Generic, "Missing 'subselect_from' attribute on inventory-subselect with config #{@views}" unless @views[:subselect_from]

          parent_crumb = @views[:subselect_from]
          parent = ::Bcome::Node::Factory.instance.bucket[parent_crumb]
          raise Bcome::Exception::CannotFindSubselectionParent, "for key '#{parent_crumb}'" unless parent
          raise Bcome::Exception::CanOnlySubselectOnInventory, "breadcrumb'#{parent_crumb}' represents a #{parent.class}'" unless parent.inventory?

          parent
        end
      end
    end
  end
end
