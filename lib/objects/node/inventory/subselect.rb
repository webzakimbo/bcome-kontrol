module Bcome::Node::Inventory
  class Subselect < ::Bcome::Node::Inventory::Base

    def initialize(*params)
      super
      raise ::Bcome::Exception::MissingSubselectionKey.new @views if !@views[:subselect_from] 
    end

    def parent_inventory
      @parent_inventory ||= load_parent_inventory
    end

    def resources
      @resources ||= ::Bcome::Node::Resources::SubselectInventory.new(:parent_crumb => @views[:subselect_from])
    end

    def nodes_loaded?
      true 
    end

    # TODO
    # Unit test the creation of these sub-selects.
    # Sub-select rationale:  1. We can get the machine yaml config down even smaller by removing duplication of nodes 2. We move a little close to merging disparate networks into one view, although unsure yet
    # on the implementation as this needs to respect differing connection parameters.

    # !!  TODO - a sub-select does not contain ssh connection stuff: this is inherited from the parent inventory: this is how we can then merge networks into views. WOW.  This is going to work 
    # TODO - subseletion may be valid but return no results, so indicate this with a friendly message

    def self.to_s
      'sub-inventory'
    end

    def reload
      # TODO - Delegate down to the parent inventory and reload that, which will refresh this view 
      super
    end

  end
end
