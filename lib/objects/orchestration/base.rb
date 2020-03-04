# frozen_string_literal: true

module Bcome::Orchestration
  class Base
    def initialize(node, arguments)
      @node = node
      @arguments = arguments
    end

    def do_execute
      raise Bcome::Exception::MissingExecuteOnRegistryObject, self.class.to_s unless respond_to?(:execute)

      execute
    end

    def method_missing(method_sym, *_arguments)
      ## A thread error deep in the bowels of IRB is not playing well with orchestration missing methods within the orchestration namespace. Until this can be resolved,
      ## I've re-implemented it here.

      raise NameError, "NameError (undefined local variable or method '#{method_sym}' for #{self.class}"
    end
  end
end
