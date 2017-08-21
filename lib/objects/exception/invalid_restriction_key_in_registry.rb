module Bcome::Exception
  class InvalidRestrictionKeyInRegistry < ::Bcome::Exception::Base
    def message_prefix
      'Invalid restriction key in registry: '
    end
  end
end
