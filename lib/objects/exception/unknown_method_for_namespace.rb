# frozen_string_literal: true

module Bcome
  module Exception
    class UnknownMethodForNamespace < ::Bcome::Exception::Base
      def message_prefix
        'unknown method or namespace'
      end
    end
  end
end
