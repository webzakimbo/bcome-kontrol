module ::Bcome::Exception
  class MissingGcpServiceScopes < ::Bcome::Exception::Base
    def message_prefix
      'Missing gcp service scopes'
    end
  end
end
