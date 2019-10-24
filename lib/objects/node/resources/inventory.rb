# frozen_string_literal: true

module Bcome::Node::Resources
  class Inventory < Bcome::Node::Resources::Base
    def <<(node)
      if existing_node = for_identifier(node.identifier)
        if existing_node.static_server? && node.dynamic_server?
          # We've got a duplicate, but we'll treat the remote node as authoritative
          # We remove the static server from our selection
          @nodes.delete(existing_node)
        else
          duplicate_nodes[node.identifier] = duplicate_nodes[node.identifier] ? (duplicate_nodes[node.identifier] + 1) : 2
          count = duplicate_nodes[node.identifier]
          node.identifier = "#{node.identifier}_#{count}"
        end
      end
      @nodes << node
    end

    def should_rename_initial_duplicate?
      true
    end

    def rename_initial_duplicate
      duplicate_nodes.each do |node_identifier, _count|
        node = for_identifier(node_identifier)
        node.identifier = "#{node.identifier}_1"
      end
    end

    def duplicate_nodes
      @duplicate_nodes ||= {}
    end

    def reset_duplicate_nodes!
      @duplicate_nodes = {}
    end

    def dynamic_nodes
      active.select(&:dynamic_server?)
    end

    def unset!
      @nodes = []
    end
  end
end
