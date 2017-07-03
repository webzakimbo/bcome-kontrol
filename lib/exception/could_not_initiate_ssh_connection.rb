module ::Bcome::Exception
  class CouldNotInitiateSshConnection < ::Bcome::Exception::Base
    def message_prefix
      'Could not initiate SSH connection. Check your SSH config settings for namespace'
    end
  end
end
