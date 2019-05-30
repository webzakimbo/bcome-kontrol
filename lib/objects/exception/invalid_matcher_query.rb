# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidMatcherQuery < ::Bcome::Exception::Base
      def message_prefix
        'Invalid matcher query'
      end
    end
  end
end
