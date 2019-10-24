# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidMachinesCacheConfig < ::Bcome::Exception::Base
      def message_prefix
        'Your machines cache configuration is invalid'
      end
    end
  end
end
