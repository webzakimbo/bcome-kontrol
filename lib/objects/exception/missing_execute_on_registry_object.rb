module ::Bcome::Exception
  class MissingExecuteOnRegistryObject < ::Bcome::Exception::Base
    def message_prefix
      "Registry orchestration object is missing an 'execute' method for registry class "
    end
  end
end
