# frozen_string_literal: true

module Bcome
  module Exception
    class CannotAuthenticateToGcp < ::Bcome::Exception::Base
      def message_prefix
        'Could not authenticate with GCP'
      end
    end
  end
end
