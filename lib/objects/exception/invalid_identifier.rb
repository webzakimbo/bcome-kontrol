# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidIdentifier < ::Bcome::Exception::Base
      def message_prefix
        'View has invalid identifier'
      end
    end
  end
end
