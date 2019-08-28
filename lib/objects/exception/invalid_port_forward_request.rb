# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidPortForwardRequest < ::Bcome::Exception::Base
      def message_prefix
        'Invalid Port Forward request'
      end
    end
  end
end
