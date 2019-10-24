# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidRegistryArgumentType < ::Bcome::Exception::Base
      def message_prefix
        'Invalid registry argument type'
      end
    end
  end
end
