# frozen_string_literal: true

module Bcome
  module Exception
    class ProxyHostNodeDoesNotHavePublicIp < ::Bcome::Exception::Base
      def message_prefix
        'Node missing public ip address, and so cannot be used as a proxy ssh server'
      end
    end
  end
end
