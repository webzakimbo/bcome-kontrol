module ::Bcome::Exception
  class InvalidNetworkConfig < ::Bcome::Exception::Base
    def message_prefix
      'Your network configuration is invalid'
    end
  end
end
