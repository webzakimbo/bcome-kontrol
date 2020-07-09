module Bcome
  module Tree

    BOTTOM_ANCHOR = "└──┈\s"
    MID_SHIPS = "├──┈\s"
    BRANCH = "│"
    LEFT_PADDING = "\s" * 3
    INGRESS = "│" 
    BLIP = "▐▆"

    def tree
      build_tree(:network_namespace_tree_data)
    end  

    def routes
      build_tree(:routing_tree_data) 
    end

    def build_tree(data_build_method)
      @lines = []
      data = send(data_build_method)

      @lines << "\n"
      @lines << "#{BLIP}\s\s\s" + "#{namespace} tree".bc_cyan
      @lines << "#{INGRESS}"

      recurse_namespace_tree_lines(data)

      @lines.each {|line|
        print "#{LEFT_PADDING}#{line}\n"
      }
    end
   
    def routing_tree_data
      @tree = {}

       # TODO - Skip inactive nodes; load nodes that haven't been loaded
       # same as for normal tree

      # For each namespace, we have many proxy chains
      proxy_chain_link.link.each do |proxy_chain, machines|
        ## Machine data
        machine_data = {}
        machines.each {|machine|
          key = machine. namespace_tree_line
          machine_data[key] = nil
        }

        ## Construct Hop data
        hops = proxy_chain.hops
        hop_lines = hops.collect(&:pretty_proxy_details)
        @tree.merge!(to_nested_hash(hop_lines, machine_data))
      end
      return @tree
    end

    def to_nested_hash(array, data)
      nested = array.reverse.inject(data) { |a, n| {  n => a }}
      nested.is_a?(String) ? { "#{nested}": nil } : nested
    end

    def network_namespace_tree_data
      @tree = {}

      if inventory?
        load_nodes if !nodes_loaded?
        return nil if resources.empty?
      end
   
      resources.sort_by(&:identifier).each do |resource|
        next if resource.hide?
        unless resource.is_a?(Bcome::Node::Inventory::Merge)
          next if resource.parent && !resource.parent.resources.is_active_resource?(resource)
        end
        @tree[resource.namespace_tree_line] = resource.resources.any? ? resource.network_namespace_tree_data : nil
      end

      return @tree       
    end

    def namespace_tree_line
      return "#{type.bc_green} #{identifier} (empty set)" if !server? && !resources.has_active_nodes?
      return "#{type.bc_green} #{identifier}"
    end

    def build_tree(data_build_method)
      data = send(data_build_method) 
    
      @lines = []
      title = "#{namespace} tree".bc_cyan
      @lines << "\n"
      @lines << "#{BLIP}\s\s\s#{title}"
      @lines << "#{INGRESS}"

      recurse_namespace_tree_lines(data)
 
      @lines.each {|line|
        print "#{LEFT_PADDING}#{line}\n"
      } 
    end

    def recurse_namespace_tree_lines(data, padding = "")
      data.each_with_index do |config, index|
        key = config[0]
        values = config[1]      

        anchor, branch = deduce_tree_structure(index, data.size)
        key_string = "#{anchor}\s#{key}"

        entry_string = "#{padding}#{key_string}"
        @lines << entry_string
  
        if values && values.is_a?(Hash)
          tab_padding = padding + branch + ("\s" * (anchor.length + 1)) 
          recurse_namespace_tree_lines(values, tab_padding)
          @lines << padding + branch
        end
      end
      return
    end

    def deduce_tree_structure(index, number_lines)
      return BOTTOM_ANCHOR, "\s" if (index + 1) == number_lines
      return MID_SHIPS, BRANCH
    end

  end
end
