# frozen_string_literal: true

module Bcome
  module Exception
    class DuplicateCommandLineArgumentKey < ::Bcome::Exception::Base
      def message_prefix
        'Duplicate command line argument key'
      end
    end
  end
end
