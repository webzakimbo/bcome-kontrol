module Bcome::Node::Resources
  class Inventory < Bcome::Node::Resources::Base
    def <<(node)
      if existing_node = for_identifier(node.identifier)
        if existing_node.static_server? && node.dynamic_server?
          # We've got a duplicate, but we'll treat the remote node as authoritative
          # We remove the static server from our selection
          @nodes.delete(existing_node)
        else
          exception_message = "#{node.identifier} is not unique within namespace #{node.parent.namespace}"
          raise Bcome::Exception::NodeIdentifiersMustBeUnique, exception_message
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
