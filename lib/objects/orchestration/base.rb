module Bcome::Orchestration
  class Base

    def initialize(node, arguments)
      @node = node
      @arguments = arguments
    end

    def do_execute
      raise ::Bcome::Exception::MissingExecuteOnRegistryObject.new "#{self.class}" unless respond_to?(:execute)
      execute
    end

  end
end
