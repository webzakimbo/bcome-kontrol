# frozen_string_literal: true

module Bcome::Node::Resources
  class Merged < Bcome::Node::Resources::Inventory
    def initialize(config)
      super
      @inventory = config[:inventory]
      run_select
    end

    def run_select
      @inventory.contributing_inventories.each { |inventory| 
        raise ::Bcome::Exception::Generic, "#{inventory.namespace} is not an inventory, and cannot be merged."  unless inventory.is_a?(::Bcome::Node::Inventory::Base)
   
        inventory.load_nodes unless inventory.nodes_loaded? 
      }

      @nodes = @inventory.contributing_inventories.collect { |inv| inv.resources.nodes }.flatten.collect(&:clone)

      @nodes.map do |node|
        node.add_list_attributes(origin: :origin_namespace)
      end

      @nodes
    end

    def update_nodes
      new_set = []

      @nodes.collect do |node|
        new_node = node.dup_with_new_parent(@inventory)
        if @inventory.override_server_identifier?
          new_node.identifier =~ /#{@inventory.override_identifier}/
          new_node.update_identifier(Regexp.last_match(1)) if Regexp.last_match(1)
        end
        # Register the new node with the registry
        ::Bcome::Registry::Loader.instance.set_command_group_for_node(new_node)
        new_set << new_node
      end
      @nodes = new_set
    end
  end
end
