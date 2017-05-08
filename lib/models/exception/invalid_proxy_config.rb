module ::Bcome::Exception
  class InvalidProxyConfig < ::Bcome::Exception::Base
    def message_prefix
      'Invalid proxy config'
    end
  end
end
