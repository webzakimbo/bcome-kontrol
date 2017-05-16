module ::Bcome::Exception
  class InvalidIdentifier < ::Bcome::Exception::Base
    def message_prefix
      'View has invalid identifier'
    end
  end
end
