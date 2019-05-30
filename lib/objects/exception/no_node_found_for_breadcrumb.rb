# frozen_string_literal: true

module Bcome
  module Exception
    class NoNodeFoundForBreadcrumb < ::Bcome::Exception::Base
      def message_prefix
        'No node exists for breadcrumb'
      end
    end
  end
end
