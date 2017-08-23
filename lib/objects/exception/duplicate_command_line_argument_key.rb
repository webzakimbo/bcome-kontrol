module ::Bcome::Exception
  class DuplicateCommandLineArgumentKey < ::Bcome::Exception::Base
    def message_prefix
      'Duplicate command line argument key'
    end
  end
end
