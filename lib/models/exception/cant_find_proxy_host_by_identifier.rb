module ::Bcome::Exception
  class CantFindProxyHostByIdentifier < ::Bcome::Exception::Base
    def message_prefix
      'Can\'t find proxy host by identifier'
    end
  end
end
