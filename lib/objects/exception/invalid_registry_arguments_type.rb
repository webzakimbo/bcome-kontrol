module ::Bcome::Exception
  class InvalidRegistryArgumentType < ::Bcome::Exception::Base
    def message_prefix
      'Invalid registry argument type'
    end
  end
end
