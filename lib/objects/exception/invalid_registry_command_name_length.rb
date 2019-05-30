# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidRegistryCommandNameLength < ::Bcome::Exception::Base
      def message_prefix
        'Invalid registry command name length: '
      end
    end
  end
end
