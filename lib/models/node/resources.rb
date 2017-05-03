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
      raise Bcome::Exception::NodeIdentifiersMustBeUnique.new(node.namespace) if for_identifier(node.identifier)
      @nodes << node
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