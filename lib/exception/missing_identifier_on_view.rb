module ::Bcome::Exception
  class MissingIdentifierOnView < ::Bcome::Exception::Base
    def message_prefix
      'One of your views is missing an identifier field'
    end
  end
end
