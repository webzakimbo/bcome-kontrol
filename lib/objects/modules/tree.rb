module Bcome
  module Tree

    BOTTOM_ANCHOR = "└───\s"
    MID_SHIPS = "├───\s"
    BRANCH = "│"

    def tree
      puts "\nNetwork Tree\n".title
      content = ".#{namespace}\n"
      list_data = tree_list(resources)
      print content + list_data[0] + "\n"
    end

    def deduce_tree_structure(index, number_lines)
      return BOTTOM_ANCHOR, "\s" if (index + 1) == number_lines
      return MID_SHIPS, BRANCH
    end

    def get_tree_lines_for_nodes(nodes)
      max_length = 0
      lines = nodes.sort_by(&:identifier).collect{|node|

        next if node.hide?
        node.load_nodes if node.inventory? && !node.nodes_loaded?
        unless node.is_a?(Bcome::Node::Inventory::Merge)
          next if node.parent && !node.parent.resources.is_active_resource?(node)
        end

        line = node.tree_line
        max_length = line.length if max_length < line.length
        [line, node]
      }.compact
      return lines, max_length
    end

    def build_tree_from_node_lines(lines_for_nodes, max_length, tab_padding)
      content = ""
      number_lines = lines_for_nodes.size

      lines_for_nodes.each_with_index do |data, index|
        anchor, branch = deduce_tree_structure(index, number_lines)

        begin
        line = data[0]
        node = data[1]
        pad_length = (max_length > line.length)  ? (1 + (max_length - line.length)) : 1
        rescue 
          raise "Caught: #{lines_for_nodes.inspect}"
        end

        full_line = "#{tab_padding}#{anchor}#{line}"
        label_start = full_line.length - line.length - anchor.length

         ## Recurse
         recursed_content = ""
         if node.resources.any?
           recursed_tab_padding = tab_padding + ("\s" * (label_start - tab_padding.length)) + branch + ("\s" * anchor.length)
           r_box_string, r_max_length = tree_list(node.resources, recursed_tab_padding)
           recursed_content += r_box_string
         end
         content += full_line + "\n"
         content += recursed_content
       end
      return content
    end

    def tree_list(nodes, tab_padding = "")
      content = ""

      ## Get all our tree lines
      lines_for_nodes, max_length = get_tree_lines_for_nodes(nodes)
      total_line_length = max_length

      ## Build our tree
      content += build_tree_from_node_lines(lines_for_nodes, max_length, tab_padding)

      return content, max_length
    end

    def tree_line
      return "#{type.bc_green} #{identifier} (empty set)" if !server? && !resources.has_active_nodes?
      return "#{type.bc_green} #{identifier}"
    end

  end
end
