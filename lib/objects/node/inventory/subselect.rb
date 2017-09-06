module Bcome::Node::Inventory
  class Subselect < ::Bcome::Node::Inventory::Base

    def initialize(*params)
      super
      raise ::Bcome::Exception::MissingSubselectionKey.new @views if !@views[:subselect_from] 
      update_nodes
    end

    def parent_inventory
      @parent_inventory ||= load_parent_inventory
    end

    def resources
      @resources ||= do_set_resources
    end

    def update_nodes
      resources.update_nodes(self)
    end

    def do_set_resources 
      ::Bcome::Node::Resources::SubselectInventory.new(:parent_inventory => parent_inventory, :filters => filters)
    end

    def nodes_loaded?
      true 
    end

    def filters
      # Flex point for filters, as obviously we need to support more than just ec2 filtering eventually
      @views[:filters] ? @views[:filters] : {}
    end

    def self.to_s
      'sub-inventory'
    end

    def do_reload
      parent_inventory.do_reload
      resources.run_subselect
      update_nodes
    end

    private

    def parent_inventory
      @parent_inventory ||= load_parent_inventory
    end

    def load_parent_inventory
      parent_crumb = @views[:subselect_from]
      parent = ::Bcome::Node::Factory.instance.bucket[parent_crumb] 
      raise ::Bcome::Exception::CannotFindSubselectionParent.new "for key '#{parent_crumb}'" unless parent
      raise ::Bcome::Exception::CanOnlySubselectOnInventory.new "breadcrumb'#{parent_crumb}' represents a #{parent.class}'" unless parent.inventory?
      parent
    end

  end
end
