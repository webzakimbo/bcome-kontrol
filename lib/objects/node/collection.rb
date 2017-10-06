module Bcome::Node
  class Collection < ::Bcome::Node::Base
    def self.to_s
      'collection'
    end

    def inventories
      inv = []
      @resources.active.each do |r|
        inv << if r.inventory?
                 r
               else
                 r.inventories
               end
      end
      inv.flatten
    end

    def filter_duplicates(original_set)
      instance_lookup = []
      filtered_set = []
      original_set.each {|server|
        unless instance_lookup.include?(server.origin_object_id)
          filtered_set << server
          instance_lookup << server.origin_object_id
        end  
      }
      filtered_set 
    end

    def machines
      set = []
      @resources.active.each do |resource|
        if resource.inventory?
          resource.load_nodes unless resource.nodes_loaded?
          set << resource.resources.active
        else
          set << resource.machines
        end
      end

      set.flatten!

      filter_duplicates(set)
    end

    def collection?
      true
    end
  end
end
