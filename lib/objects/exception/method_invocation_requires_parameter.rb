# frozen_string_literal: true

module Bcome
  module Exception
    class MethodInvocationRequiresParameter < ::Bcome::Exception::Base
      def message_prefix
        'Method invocation requires parameter: '
      end
    end
  end
end
