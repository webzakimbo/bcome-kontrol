# frozen_string_literal: true

module Bcome
  module Exception
    class CannotFindSubselectionParent < ::Bcome::Exception::Base
      def message_prefix
        'Cannot find subselection parent'
      end
    end
  end
end
