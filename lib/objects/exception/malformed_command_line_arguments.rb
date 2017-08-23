module ::Bcome::Exception
  class MalformedCommandLineArguments < ::Bcome::Exception::Base
    def message_prefix
      'Malformed command line arguments'
    end
  end
end
