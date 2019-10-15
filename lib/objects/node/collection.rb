# frozen_string_literal: true

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
      original_set.each do |server|
        unless instance_lookup.include?(server.origin_object_id)
          filtered_set << server
          instance_lookup << server.origin_object_id
        end
      end
      filtered_set
    end

    def machines(skip_for_hidden = true)
      set = []

      resources = skip_for_hidden ? @resources.active.reject(&:hide?) : @resources.active

      resources.each do |resource|
        if resource.inventory?
          resource.load_nodes unless resource.nodes_loaded?
          set << resource.resources.active
        else
          set << resource.machines(skip_for_hidden)
        end
      end

      set.flatten!
      filtered_machines = filter_duplicates(set)
      filtered_machines
    end

    def collection?
      true
    end
  end
end
