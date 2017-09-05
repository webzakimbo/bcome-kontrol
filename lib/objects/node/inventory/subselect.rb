module Bcome::Node::Inventory
  class Subselect < ::Bcome::Node::Inventory::Base

    def initialize(*params)
      super
      raise ::Bcome::Exception::MissingSubselectionKey.new @views if !@views[:subselect_from] 
      #load_parent_inventory
      # raise ::Bcome::Exception::InvalidSubSelectionKey.new @views if key is not a valid crumb
      # load the nodes on the parent if not yet loaded
    end

    def load_parent_inventory
      parent_crumb = @views[:subselect_from]
      @parent_crumb = ::Bcome::Orchestrator.instance.get(parent_crumb)
      raise ::Bcome::Exception::SubSelectionMissingParent.new @views if !@parent_crumb

      raise ::Bcome::Exception::CanOnlySubSelectOnInventory.new @views unless @parent_crumb.inventory? # Includes both defined inventory, and other sub-selections
    end
 
 #   def resources
 #     @resources ||= 
 #   end 





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

    def load_nodes
      puts "Gotcha: Load from defined parent"
      # validate subselect has defined parent
      # traverse to it, and then cache on the subselect
      # load nodes from that, and apply the subselect
    end


  end
end
