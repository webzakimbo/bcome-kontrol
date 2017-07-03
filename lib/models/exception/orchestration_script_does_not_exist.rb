module Bcome::Exception
  class OrchestrationScriptDoesNotExist < ::Bcome::Exception::Base
    def message_prefix
      'Cannot find orchestration file at path: '
    end
  end
end
