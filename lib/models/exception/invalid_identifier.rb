module ::Bcome::Exception
  class InvalidIdentifier < ::Bcome::Exception::Base
    def message_prefix
      'Invalid identifier on view'
    end
  end
end
