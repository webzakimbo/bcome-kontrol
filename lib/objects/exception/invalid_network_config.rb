# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidNetworkConfig < ::Bcome::Exception::Base
      def message_prefix
        'Your network configuration is invalid'
      end
    end
  end
end
