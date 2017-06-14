module Bcome::Exception
  class UnknownMethodForNamespace < ::Bcome::Exception::Base
    def message_prefix
      'unknown method '
    end
  end
end
