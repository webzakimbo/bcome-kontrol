module Bcome::Node::Resources
  class SubselectInventory < Bcome::Node::Resources::Inventory

    def initialize(config)
      @config = config
      super
      run_subselect_on_parent
    end

    def run_subselect_on_parent
      parent_inventory.load_nodes unless parent_inventory.nodes_loaded?
      # TODO - this is our flex point: subselected nodes are the same as the parents
      # TODO - pass in ec2_filters & test for presence of filters. empty filters = {}
      # TODO - sub inventories that are the union of two or more other inventories (merged inventories?)
      # TODO -  def save ; puts "'save' is not availble on sub-selected views" ; end
      @nodes = parent_inventory.resources.nodes
    end

    def parent_crumb
      @config[:parent_crumb]
    end

    def parent_inventory
      @parent_inventory ||= load_parent_inventory
    end

    def load_parent_inventory
      parent_crumb = @config[:parent_crumb]
      parent = ::Bcome::Node::Factory.instance.bucket[parent_crumb]
      raise ::Bcome::Exception::CannotFindSubselectionParent.new "for key '#{parent_crumb}'" unless parent   
      raise ::Bcome::Exception::CanOnlySubselectOnInventory.new "breadcrumb'#{parent_crumb}' represents a #{parent.class}'" unless parent.inventory? 
      parent
    end


  end
end
