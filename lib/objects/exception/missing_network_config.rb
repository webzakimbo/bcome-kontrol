module ::Bcome::Exception
  class MissingNetworkConfig < ::Bcome::Exception::Base
    def message_prefix
      'Cannot find network config at'
    end
  end
end
