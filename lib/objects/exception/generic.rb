# frozen_string_literal: true

module Bcome
  module Exception
    class Generic < ::Bcome::Exception::Base
      def message_prefix
        'GCP client error'
      end
    end
  end
end
