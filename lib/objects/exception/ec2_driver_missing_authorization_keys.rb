# frozen_string_literal: true

module Bcome
  module Exception
    class Ec2DriverMissingAuthorizationKeys < ::Bcome::Exception::Base
      def message_prefix
        "Missing authorization keys for AWS. Expected to find keys at "
      end
    end
  end
end
