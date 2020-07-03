# frozen_string_literal: true

module Bcome::Node::Resources
  class Merged < Bcome::Node::Resources::Inventory
    def initialize(config)
      super
      @inventory = config[:inventory]
      run_select
    end

    def run_select
      @inventory.contributing_inventories.each do |inventory|
        raise ::Bcome::Exception::Generic, "#{inventory.namespace} is not an inventory, and cannot be merged." unless inventory.is_a?(::Bcome::Node::Inventory::Base)

        inventory.load_nodes unless inventory.nodes_loaded?
      end

      @nodes = @inventory.contributing_inventories.collect { |inv| inv.resources.nodes }.flatten.collect(&:clone)

      @nodes.map do |node|
        renamed_node_for_merged_inventory(node)
        node.add_list_attributes(origin: :origin_namespace)
      end

      @nodes
    end

    def renamed_node_for_merged_inventory(node)
      node.identifier = node.namespace.gsub(":", "_")
    end

    def update_nodes
      new_set = []

      @nodes.collect do |node|
        new_node = node.dup_with_new_parent(@inventory)
        set_overrides(@inventory, new_node)

        # Register the new node with the registry
        ::Bcome::Registry::Loader.instance.set_command_group_for_node(new_node)
        new_set << new_node
      end
      @nodes = new_set
    end
  end
end
