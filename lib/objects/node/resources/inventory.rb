module Bcome::Node::Resources
  class Inventory < Bcome::Node::Resources::Base
    def <<(node)
      if existing_node = for_identifier(node.identifier)
        if existing_node.static_server? && node.dynamic_server?
          # We've got a duplicate, but we'll treat the remote node as authoritative
          # We remove the static server from our selection
          @nodes.delete(existing_node)
        else

          # If we find a node with a duplicate identifier, we'll add a digit to the end
          existing_node.identifier =~ /.+(\d)/
          digit = $1

          if digit
            node.identifier = "#{node.identifier}#{digit.to_i + 1}"
          else
            node.identifier = "#{node.identifier}2"
            existing_node.identifier = "#{existing_node.identifier}1"  
          end        
        
        end
      end
      @nodes << node
    end

    def dynamic_nodes
      active.select(&:dynamic_server?)
    end

    def unset!
      @nodes = []
    end
  end
end
