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

    def run(raw_commands)
      # TODO - what should be the loading strategy where nodes are cached & not yet loaded, and we're working on a whole selection?
      # TODO - print server names in context when executing commands down a deep tree
      inventories.pmap{|inventory|
        inventory.load_dynamic_nodes unless inventory.nodes_loaded?
      }

      inventories.pmap{|inventory|
        inventory.run(raw_commands)
      }
    end

  end
end
