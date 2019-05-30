module Bcome::Exception
  class MissingGcpAuthenticationScheme < ::Bcome::Exception::Base
    def message_prefix
      'Missing GCP authentication scheme'
    end
  end
end
