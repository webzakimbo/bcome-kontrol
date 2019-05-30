# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidProxyConfig < ::Bcome::Exception::Base
      def message_prefix
        'Invalid proxy config'
      end
    end
  end
end
