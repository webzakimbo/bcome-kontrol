module Bcome::Exception
  class InvalidSshConfig < ::Bcome::Exception::Base
    def message_prefix
      "Invalid Ssh Config"
    end
  end
end 
