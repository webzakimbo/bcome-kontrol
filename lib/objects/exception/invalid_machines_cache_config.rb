module ::Bcome::Exception
  class InvalidMachinesCacheConfig < ::Bcome::Exception::Base
    def message_prefix
      'Your machines cache configuration is invalid'
    end
  end
end
