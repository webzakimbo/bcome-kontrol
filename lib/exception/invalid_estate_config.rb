module ::Bcome::Exception
  class InvalidEstateConfig < ::Bcome::Exception::Base
    def message_prefix
      'Your estate configuration is invalid'
    end
  end
end
