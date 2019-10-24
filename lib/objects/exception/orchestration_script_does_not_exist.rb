# frozen_string_literal: true

module Bcome
  module Exception
    class OrchestrationScriptDoesNotExist < ::Bcome::Exception::Base
      def message_prefix
        'Cannot find orchestration file at path: '
      end
    end
  end
end
