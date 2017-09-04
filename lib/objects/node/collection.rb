module Bcome::Node
  class Collection < ::Bcome::Node::Base
    def self.to_s
      'collection'
    end

    def inventories
      inv = []
      @resources.active.each do |r|
        inv << if r.is_a?(Bcome::Node::Inventory)
                 r
               else
                 r.inventories
               end
      end
      inv.flatten
    end

    def machines
      m = []
      @resources.active.each do |resource|
        if resource.is_a?(::Bcome::Node::Inventory)
          resource.load_nodes unless resource.nodes_loaded?
          m << resource.resources.active
        else
          m << resource.machines
        end
      end
      m.flatten
    end

    def collection?
      true
    end

  end
end
