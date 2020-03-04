# frozen_string_literal: true

module Bcome
  module Exception
    class CouldNotRetrieveTerraformOutput < ::Bcome::Exception::Base
      def message_prefix
        'Could not retrieve terraform output'
      end
    end
  end
end
