# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidNetworkDriverType < ::Bcome::Exception::Base
      def message_prefix
        'Invalid network driver type'
      end
    end
  end
end
