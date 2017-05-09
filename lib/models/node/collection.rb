module Bcome::Node
  class Collection < ::Bcome::Node::Base

    def self.to_s
      'collection'
    end

    def inventories
      inv = []
      @resources.each do |r|
        if r.is_a?(Bcome::Node::Inventory)
          inv << r
        else
          inv << r.inventories
        end
      end    
      return inv.flatten
    end

    def run(raw_commands)
      inventories.pmap{|inventory|
        inventory.run(raw_commands)
      }
    end

  end
end
