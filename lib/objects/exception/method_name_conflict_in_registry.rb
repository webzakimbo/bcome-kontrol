# frozen_string_literal: true

module Bcome
  module Exception
    class MethodNameConflictInRegistry < ::Bcome::Exception::Base
      def message_prefix
        'Method name conflict in registry. The following console_command name in your registry conflicts with either a reserved bcome method name, or another method name in your registry: '
      end
    end
  end
end
