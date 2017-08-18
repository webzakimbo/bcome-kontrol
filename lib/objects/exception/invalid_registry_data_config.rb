module ::Bcome::Exception
  class InvalidRegistryDataConfig < ::Bcome::Exception::Base
    def message_prefix
      'Invalid config in registry file '
    end
  end
end
