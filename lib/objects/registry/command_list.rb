# frozen_string_literal: true

module Bcome::Registry
  class CommandList
    include Singleton

    attr_reader :list

    def initialize
      @list = {}
      @groups_for_nodes = {}
    end

    def add_group_for_node(node, group)
      @groups_for_nodes[node.keyed_namespace] = group
    end

    def group_for_node(node)
      @groups_for_nodes[node.keyed_namespace]
    end

    def register(node, command_name)
      @list[node.keyed_namespace] ? (@list[node.keyed_namespace] << command_name) : (@list[node.keyed_namespace] = [command_name])
    end

    def command_in_list?(node, command_name)
      @list.key?(node.keyed_namespace) && @list[node.keyed_namespace].include?(command_name.to_sym)
    end

    def teardown!
      @groups_for_nodes = {}
      @list = {}
    end
  end
end
