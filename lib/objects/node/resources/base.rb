module Bcome::Node::Resources
  class Base
    include Enumerable

    attr_reader :nodes

    def initialize(*_params)
      @nodes = []
      @disabled_resources = []
    end

    def each
      @nodes.each { |node| yield(node) }
    end

    def <<(node)
      existing_node = for_identifier(node.identifier)
      if existing_node
        exception_message = "#{node.identifier} is not unique within namespace #{node.parent.namespace}"
        raise Bcome::Exception::NodeIdentifiersMustBeUnique, exception_message
      end
      @nodes << node
    end

    def clear!
      @disabled_resources = []
    end
    alias enable! clear!

    def do_disable(identifier)
      if identifier.is_a?(Array)
        identifier.each { |id| disable(id) }
      else
        disable(identifier)
      end
      nil
    end

    def do_enable(identifier)
      if identifier.is_a?(Array)
        identifier.each { |id| enable(id) }
      else
        enable(identifier)
      end
      nil
    end

    def disable!
      @disabled_resources = @nodes
    end

    def disable(identifier)
      resource = for_identifier(identifier)
      raise Bcome::Exception::NoNodeNamedByIdentifier, identifier unless resource
      @disabled_resources << resource unless @disabled_resources.include?(resource)
    end

    def enable(identifier)
      resource = for_identifier(identifier)
      raise Bcome::Exception::NoNodeNamedByIdentifier, identifier unless resource
      @disabled_resources -= [resource]
    end

    def clear!
      @disabled_resources = []
      nil
    end

    def active
      @nodes - @disabled_resources
    end

    def is_active_resource?(resource)
      active.include?(resource)
    end

    def for_identifier(identifier)
      resource = @nodes.select { |node| node.identifier == identifier }.first
      resource
    end

    def empty?
      @nodes.empty?
    end

    def has_active_nodes?
      active.any?
    end

    def size
      @nodes.size
    end

    def first
      @nodes.first
    end
  end
end
