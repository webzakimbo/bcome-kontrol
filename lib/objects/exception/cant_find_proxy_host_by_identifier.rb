# frozen_string_literal: true

module Bcome
  module Exception
    class CantFindProxyHostByIdentifier < ::Bcome::Exception::Base
      def message_prefix
        'Can\'t find proxy host by identifier'
      end
    end
  end
end
