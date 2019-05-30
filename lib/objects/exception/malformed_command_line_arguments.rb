# frozen_string_literal: true

module Bcome
  module Exception
    class MalformedCommandLineArguments < ::Bcome::Exception::Base
      def message_prefix
        'Malformed command line arguments'
      end
    end
  end
end
