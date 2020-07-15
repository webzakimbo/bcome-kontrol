module Bcome
  module Tree

    include Bcome::Draw

    def tree
      title_prefix = "Namespace tree"
      build_tree(:network_namespace_tree_data, title_prefix)
    end  

    def routes
      title_prefix = "Ssh connection routes"
      build_tree(:routing_tree_data, title_prefix) 
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
          key = machine.routing_tree_line
          machine_data[key] = nil
        }

        ## Construct Hop data
        hops = proxy_chain.hops
        hop_lines = hops.enum_for(:each_with_index).collect{|hop,index| hop.pretty_proxy_details(index + 1) }

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

    def routing_tree_line
      return [
        "#{type}".bc_cyan, 
        "namespace:\s".bc_green + namespace,
        "ip address\s".bc_green + "#{internal_ip_address}",
        "user\s".bc_green + ssh_driver.user
      ] 
    end

    def build_tree(data_build_method, title_prefix)
      data = send(data_build_method) 
    
      @lines = []
      title = "#{title_prefix.informational}\s#{namespace}"
      @lines << "\n"
      @lines << "#{BLIP}\s\s\s#{title}"
      @lines << "#{INGRESS}"

      if data.nil?
        parent.build_tree(data_build_method)
        return
      end
    
      recurse_tree_lines(data)
 
      @lines.each {|line|
        print "#{LEFT_PADDING}#{line}\n"
      }

      print "\n\n" 
    end

    def recurse_tree_lines(data, padding = "")

       @lines << padding + BRANCH

      data.each_with_index do |config, index|
        key = config[0]
        values = config[1]      

        anchor, branch = deduce_tree_structure(index, data.size)

        labels = key.is_a?(Array) ? key : [key]

        labels.each_with_index do |label, index|
          if index == 0  # First line
            key_string = "#{anchor}\s#{label}"
          else # Any subsequent line
            key_string = "#{branch}#{"\s" * 4}\s#{label}"
          end

          entry_string = "#{padding}#{key_string}"
          @lines << entry_string

        end # End labels group  

        if labels.size > 1
          @lines << "#{padding}#{branch}"
        end 

        if values && values.is_a?(Hash)
          tab_padding = padding + branch + ("\s" * (anchor.length + 4)) 
          recurse_tree_lines(values, tab_padding)
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
