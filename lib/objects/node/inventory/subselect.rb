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

    # TODO - messy as FUCK
    def update_nodes
      resources.update_nodes(self)
    end

    def do_set_resources 
      ::Bcome::Node::Resources::SubselectInventory.new(:parent_crumb => @views[:subselect_from], :filters => filters)
    end

    def nodes_loaded?
      true 
    end

    def filters
      # Flex point for filters, as obviously we need to support more than just ec2 filtering eventually
      @views[:filters] ? @views[:filters] : {}
    end

    # TODO
    # TODO - test creating a subselet from another subselect
    # TODO - if not available servers, then  "No servers found"
    # Unit test the creation of these sub-selects.
    # !!  TODO - a sub-select does not contain ssh connection stuff: this is inherited from the parent inventory: this is how we can then merge networks into views. WOW.  This is going to work 
    # TODO - subseletion may be valid but return no results, so indicate this with a friendly message
    # TODO - sub inventories that are the union of two or more other inventories (merged inventories?)
    # TODO -  def save ; puts "'save' is not availble on sub-selected views" ; end

    def self.to_s
      'sub-inventory'
    end

    def reload
      # TODO - Delegate down to the parent inventory and reload that, which will refresh this view 
      super
    end

  end
end
