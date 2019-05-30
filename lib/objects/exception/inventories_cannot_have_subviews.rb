# frozen_string_literal: true

module Bcome
  module Exception
    class InventoriesCannotHaveSubViews < ::Bcome::Exception::Base
      def message_prefix
        "You can't configure an inventory with subviews"
      end
    end
  end
end
