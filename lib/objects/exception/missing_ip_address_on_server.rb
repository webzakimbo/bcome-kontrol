# frozen_string_literal: true

module Bcome
  module Exception
    class MissingIpaddressOnServer < ::Bcome::Exception::Base
      def message_prefix
        'A static server must specify either a public or internal ip address'
      end
    end
  end
end
