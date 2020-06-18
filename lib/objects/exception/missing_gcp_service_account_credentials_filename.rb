# frozen_string_literal: true

module Bcome
  module Exception
    class MissingGcpServiceAccountCredentialsFilename < ::Bcome::Exception::Base
      def message_prefix
        "Cannot authenticate with GCP - missing service account credentials file name in networks.yml.  Define this with a 'service_account_credentials' key"
      end
    end
  end
end
