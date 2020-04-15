# frozen_string_literal: true

module Bcome
  module Exception
    class GcpAuthServiceAccountMissingCredentials < ::Bcome::Exception::Base
      def message_prefix
        'Expected GCP service account credentials at'
      end
    end
  end
end
