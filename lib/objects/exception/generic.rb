module Bcome::Exception
  class Generic < ::Bcome::Exception::Base
    def message_prefix
      'GCP client error'
    end
  end
end
