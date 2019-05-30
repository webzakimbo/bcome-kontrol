# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidRegexpMatcherInRegistry < ::Bcome::Exception::Base
      def message_prefix
        'Invalid regex matcher in registry '
      end
    end
  end
end
