# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidBreadcrumb < ::Bcome::Exception::Base
      def message_prefix
        'Invalid breadcrumb: '
      end
    end
  end
end
