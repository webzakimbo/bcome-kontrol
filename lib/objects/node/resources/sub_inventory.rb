module Bcome::Node::Resources
  class SubselectInventory < Bcome::Node::Resources::Inventory

    def initialize(config)
      @config = config

      # TODO
      # 1. Need a better mechanism of finding a context. Rather than traversing, can we just grab it from memory (another singleton), in a way that's not
      # dependent on the estate? That way we can stack things up at runtime.... problem with this approach is that it requires things to be created & and then asked
      # for in order.
      # ~OR~
      # 2. Don't rely on the estate at all.  Lazy load items from sub-selects. To do this we'll need to get around the issue of the resources wrapper being create and utilised at init.
      super
    end

    def parent_crumb
      @config[:parent_crumb]
    end

    def nodes
      parent_inventory.resources.nodes
    end

    def parent_inventory
      @parent_inventory ||= load_parent_inventory
    end

    def load_parent_inventory
      parent_crumb = @config[:parent_crumb]
      @parent_crumb = ::Bcome::Orchestrator.instance.get(parent_crumb)
      raise ::Bcome::Exception::CanOnlySubselectOnInventory.new "breadcrumb'#{parent_crumb}' represents a #{@parent_crumb.class}'" unless @parent_crumb.inventory? 
      @parent_crumb
    end


  end
end
