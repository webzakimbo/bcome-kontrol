# frozen_string_literal: true

module Bcome
  module Exception
    class MissingGcpAuthenticationScheme < ::Bcome::Exception::Base
      def message_prefix
        'Missing GCP authentication scheme'
      end
    end
  end
end
