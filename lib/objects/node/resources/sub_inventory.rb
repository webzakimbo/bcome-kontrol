# frozen_string_literal: true

module Bcome::Node::Resources
  class SubselectInventory < Bcome::Node::Resources::Inventory
    def initialize(config)
      @config = config
      super
      run_subselect
    end

    def run_subselect
      parent_inventory.load_nodes unless parent_inventory.nodes_loaded?
      new_set = parent_inventory.resources.nodes

      # ...by_tags: ec2
      # ...by_label: gcp
      new_set = filter_by_tags_or_label(new_set)

      @nodes = new_set
    end

    def update_nodes(inventory)
      new_set = []

      @nodes.collect do |node|
        new_node = node.dup_with_new_parent(inventory)
        set_overrides(inventory, new_node)        

        # Register the new node with the registry
        ::Bcome::Registry::Loader.instance.set_command_group_for_node(new_node)

        new_set << new_node
      end
      @nodes = new_set
    end

    def filter_by_tags_or_label(nodes)
      tag_filters.each do |key, values|
        nodes = nodes.select { |node| node.has_tagged_value?(key, values) }
      end
      nodes
    end

    def parent_crumb
      @config[:parent_crumb]
    end

    def filters
      @config[:filters]
    end

    def tag_filters
      filters[:by_tag] || filters[:by_label] || filters
    end

    def parent_inventory
      @config[:parent_inventory]
    end
  end
end
