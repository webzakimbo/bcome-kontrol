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

      # Filter by ec2_filters
      new_set = filter_by_tags(new_set)

      @nodes = new_set
    end
  
    def update_nodes(inventory)
      new_set = []

      @nodes.collect{|node| 
        new_node = node.dup_with_new_parent(inventory) 
        if inventory.override_server_identifier?
          new_node.identifier =~ /#{inventory.override_identifier}/
          new_node.update_identifier(Regexp.last_match(1)) if Regexp.last_match(1)
        end
        new_set << new_node
      } 
      @nodes = new_set
    end

    def filter_by_tags(nodes)
      tag_filters.each do |key, values|
        nodes = nodes.select{|node| node.has_tagged_value?(key, values) }
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
      filters[:by_tag] ? filters[:by_tag] : {}
    end

    def parent_inventory
      @config[:parent_inventory]
    end

  end
end
