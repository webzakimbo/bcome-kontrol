module Bcome::Exception
  class InvalidGcpAuthenticationScheme < ::Bcome::Exception::Base
    def message_prefix
      'Invalid authentication scheme'
    end
  end
end
