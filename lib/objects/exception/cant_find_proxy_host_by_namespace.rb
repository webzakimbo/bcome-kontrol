# frozen_string_literal: true

module Bcome
  module Exception
    class CantFindProxyHostByNamespace < ::Bcome::Exception::Base
      def message_prefix
        'Can\'t find proxy host by namespace'
      end
    end
  end
end
