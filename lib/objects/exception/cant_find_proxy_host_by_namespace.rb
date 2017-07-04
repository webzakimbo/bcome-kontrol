module ::Bcome::Exception
  class CantFindProxyHostByNamespace < ::Bcome::Exception::Base
    def message_prefix
      'Can\'t find proxy host by namespace'
    end
  end
end
