module Bcome::Registry
  class CommandList

    include Singleton

    attr_reader :list

    def initialize
      @list = {}
    end  

    def register(node, command_name)
      @list[node.namespace] ? (@list[node.namespace] << command_name) : (@list[node.namespace] = [command_name])
    end

    def command_in_list?(node, command_name)
      puts "NS: #{node.namespace}" +  @list.inspect
      @list.has_key?(node.namespace) && @list[node.namespace].include?(command_name.to_sym)
    end

  end
end
