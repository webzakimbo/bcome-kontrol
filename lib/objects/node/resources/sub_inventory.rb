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
      @parent_inventory ||= load_parent_inventory
    end

    def load_parent_inventory
      parent_crumb = @config[:parent_crumb]
      parent = ::Bcome::Node::Factory.instance.bucket[parent_crumb]  # TODO - this is a better way of grabbing a context than ORCH.get which does a traverse.  REPLACE
      raise ::Bcome::Exception::CannotFindSubselectionParent.new "for key '#{parent_crumb}'" unless parent   
      raise ::Bcome::Exception::CanOnlySubselectOnInventory.new "breadcrumb'#{parent_crumb}' represents a #{parent.class}'" unless parent.inventory? 
      parent
    end


  end
end
