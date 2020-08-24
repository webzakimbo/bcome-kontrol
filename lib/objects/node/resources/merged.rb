# frozen_string_literal: true

module Bcome::Node::Resources
  class Merged < Bcome::Node::Resources::Inventory
    def initialize(config)
      super
      @inventory = config[:inventory]
      @nodes = []
      run_select
    end

    def run_select
      @inventory.contributing_inventories.each do |inventory|
        raise ::Bcome::Exception::Generic, "#{inventory.namespace} is not an inventory, and cannot be merged." unless inventory.is_a?(::Bcome::Node::Inventory::Base)

        inventory.load_nodes unless inventory.nodes_loaded?
      end

      contributing_nodes = @inventory.contributing_inventories.collect { |inv| inv.resources.nodes }.flatten
      dup_nodes(contributing_nodes)

      @nodes
    end

    def dup_nodes(contributing_nodes)
      contributing_nodes.each do |original_node|
        # Duplicate the node, setting its origin inventory to this one, and
        # resetting its ssh_driver to the original node's driver.
        new_node = original_node.dup_with_new_parent(@inventory)
        set_overrides(@inventory, new_node)
        new_node.ssh_driver = original_node.ssh_driver

        # Rename the node as contributing inventories may provide duplicate node names
        rename_node_for_merged_inventory(original_node, new_node)

        # Register the new node with the registry
        ::Bcome::Registry::Loader.instance.set_command_group_for_node(new_node)

        @nodes << new_node
      end
    end

    def rename_node_for_merged_inventory(original_node, new_node)
      new_node.identifier = original_node.namespace.gsub(':', '_')
    end
  end
end
