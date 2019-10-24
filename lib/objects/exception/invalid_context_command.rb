# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidContextCommand < ::Bcome::Exception::Base
      def message_prefix
        'Invalid config in registry file '
      end
    end
  end
end
