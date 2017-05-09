module Bcome::Node
  class Resources

    include Enumerable

    def initialize
      @nodes = []
    end

    def each(&block)
      @nodes.each {|node| block.call(node) }
    end

    def <<(node)
      if for_identifier(node.identifier)
        clear!
        exception_message = "#{node.identifier} is not unique within namespace #{node.parent.namespace}"
        raise Bcome::Exception::NodeIdentifiersMustBeUnique.new(exception_message)
      else
        @nodes << node
      end
    end

    def clear!
      @nodes = []
    end

    def for_identifier(identifier)
      @nodes.select{|node| node.identifier == identifier }.first
    end

    def empty?
      @nodes.empty?
    end  

    def size
      @nodes.size
    end

    def first
      @nodes.first
    end

  end
end
