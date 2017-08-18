module ::Bcome::Exception
  class InvalidContextCommand < ::Bcome::Exception::Base
    def message_prefix
      'Invalid config in registry file '
    end
  end
end
