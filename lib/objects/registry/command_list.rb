module Bcome::Registry
  class CommandList

    include Singleton

    attr_reader :list

    def initialize
      @list = {}
      @groups_for_nodes = {}
    end  

    def add_group_for_node(node, group)
      @groups_for_nodes[node.namespace] = group
    end

    def group_for_node(node)
      @groups_for_nodes[node.namespace]
    end
    
    def register(node, command_name)
      @list[node.namespace] ? (@list[node.namespace] << command_name) : (@list[node.namespace] = [command_name])
    end

    def command_in_list?(node, command_name)
      @list.has_key?(node.namespace) && @list[node.namespace].include?(command_name.to_sym)
    end

    def teardown!
      @groups_for_nodes = {}
      @list = {}
    end

  end
end
