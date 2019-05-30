# frozen_string_literal: true

module Bcome
  module Exception
    class MissingGcpServiceScopes < ::Bcome::Exception::Base
      def message_prefix
        'Missing gcp service scopes'
      end
    end
  end
end
