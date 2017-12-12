module Bcome::Exception
  class InvalidRegistryCommandNameLength < ::Bcome::Exception::Base
    def message_prefix
      'Invalid registry command name length: '
    end
  end
end
