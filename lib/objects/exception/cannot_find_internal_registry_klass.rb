# frozen_string_literal: true

module Bcome
  module Exception
    class CannotFindInternalRegistryKlass < ::Bcome::Exception::Base
      def message_prefix
        'Could not initialize orchestration method '
      end
    end
  end
end
