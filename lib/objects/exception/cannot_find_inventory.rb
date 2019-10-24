# frozen_string_literal: true

module Bcome
  module Exception
    class CannotFindInventory < ::Bcome::Exception::Base
      def message_prefix
        'Cannot find inventory'
      end
    end
  end
end
