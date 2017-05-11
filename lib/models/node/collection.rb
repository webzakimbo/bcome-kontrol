module Bcome::Node
  class Collection < ::Bcome::Node::Base

    def self.to_s
      'collection'
    end

    def inventories
      inv = []
      @resources.active.each do |r|
        if r.is_a?(Bcome::Node::Inventory)
          inv << r
        else
          inv << r.inventories
        end
      end    
      return inv.flatten
    end

    def machines
      # TODO - what should be the loading strategy where nodes are cached & not yet loaded, and we're working on a whole selection?
      # TODO - print server names in context when executing commands down a deep tree
      m = []
      @resources.active.each {|resource|
        if resource.is_a?(::Bcome::Node::Inventory)
          resource.load_dynamic_nodes unless resource.nodes_loaded?
          m << resource.resources.active
        else
          m << resource.machines
        end  
      }
      return m.flatten
    end

  end
end
