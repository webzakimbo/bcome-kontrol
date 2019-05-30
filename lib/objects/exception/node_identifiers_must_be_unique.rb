# frozen_string_literal: true

module Bcome
  module Exception
    class NodeIdentifiersMustBeUnique < ::Bcome::Exception::Base
      def message_prefix
        'Node identifiers cannot be ambiguous: '
      end
    end
  end
end
