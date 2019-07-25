# frozen_string_literal: true

module Bcome
  module Exception
    class MissingInventoryContributors < ::Bcome::Exception::Base
      def message_prefix
        'You must set the inventory contributors when defining a merged inventory'
      end
    end
  end
end
