module Bcome::Node
  class Resources

    include Enumerable

    def initialize
      @nodes = []
      @disabled_resources = []
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

    def do_disable(identifier)
      if identifier.is_a?(Array)
        identifier.each {|id| disable(id) }
      else
        disable(identifier)
      end
      return
    end

    def do_enable(identifier)
      if identifier.is_a?(Array)
        identifier.each {|id| enable(id) }
      else
        enable(identifier)
      end
      return
    end

    def disable!
      @disabled_resources = @nodes
    end

    def disable(identifier)
      resource = for_identifier(identifier)
      raise Bcome::Exception::NoNodeNamedByIdentifier.new(identifier) unless resource
      @disabled_resources << resource unless @disabled_resources.include?(resource)
    end

    def enable(identifier)
      resource = for_identifier(identifier)
      raise Bcome::Exception::NoNodeNamedByIdentifier.new(identifier) unless resource
      @disabled_resources -= [resource]
    end

    def clear!
      @disabled_resources = []
      return
    end

    def active
      @nodes - @disabled_resources
    end

    def is_active_resource?(resource)
      active.include?(resource)
    end

    def for_identifier(identifier)
      resource = @nodes.select{|node| node.identifier == identifier }.first
      return resource 
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
