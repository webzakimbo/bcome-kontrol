module ::Bcome::Exception
  class MissingIpaddressOnServer < ::Bcome::Exception::Base
    def message_prefix
      'A static server must specify either a public or internal ip address'
    end
  end
end
