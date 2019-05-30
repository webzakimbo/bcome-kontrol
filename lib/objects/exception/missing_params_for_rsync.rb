# frozen_string_literal: true

module Bcome
  module Exception
    class MissingParamsForRsync < ::Bcome::Exception::Base
      def message_prefix
        ''
      end
    end
  end
end
