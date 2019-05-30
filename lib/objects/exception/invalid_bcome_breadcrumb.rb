# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidBcomeBreadcrumb < ::Bcome::Exception::Base
      def message_prefix
        'Invalid bcome breadcrumb'
      end
    end
  end
end
