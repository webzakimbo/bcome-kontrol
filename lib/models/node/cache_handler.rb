module Bcome::Node
  class CacheHandler

    def initialize(inventory_node)
      @inventory_node = inventory_node
    end

    def do_cache_nodes!
      dynamic_nodes = @inventory_node.resources.dynamic_nodes
      write_to_cache!(dynamic_nodes) if dynamic_nodes.any?
    end

    def write_to_cache!(nodes)
      static_server_data = dynamic_nodes_to_cache_hash(nodes)
      @inventory_node.views.has_key?(:static_servers) ? (@inventory_node.views[:static_servers] << static_server_data) : (@inventory_node.views[:static_servers] = static_server_data)
      return
    end  

    def dynamic_nodes_to_cache_hash(nodes)
      nodes.collect{|node| node.cache_data }
    end  

  end
end
