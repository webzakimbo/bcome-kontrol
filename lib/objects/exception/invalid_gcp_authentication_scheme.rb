# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidGcpAuthenticationScheme < ::Bcome::Exception::Base
      def message_prefix
        'Invalid authentication scheme'
      end
    end
  end
end
