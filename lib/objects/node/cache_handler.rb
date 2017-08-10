module Bcome::Node
  class CacheHandler

    def initialize(inventory_node)
      @inventory_node = inventory_node
    end

    def do_cache_nodes!
      @inventory_node.load_nodes unless @inventory_node.nodes_loaded?
      all_nodes = @inventory_node.resources.active
      write_to_in_memory_cache!(all_nodes) if all_nodes.any?
    end

    def write_to_in_memory_cache!(nodes)
      @inventory_node.views[:load_from_cache] = true
      static_server_data = dynamic_nodes_to_cache_hash(nodes)
      @inventory_node.views[:static_servers] = static_server_data
      return
    end  

    def dynamic_nodes_to_cache_hash(nodes)
      nodes.collect{|node| node.cache_data }
    end  

  end
end
