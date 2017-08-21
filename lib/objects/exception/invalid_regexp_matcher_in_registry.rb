module ::Bcome::Exception
  class InvalidRegexpMatcherInRegistry < ::Bcome::Exception::Base
    def message_prefix
      'Invalid regex matcher in registry '
    end
  end
end
