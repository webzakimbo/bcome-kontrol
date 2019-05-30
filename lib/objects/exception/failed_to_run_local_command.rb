# frozen_string_literal: true

module Bcome
  module Exception
    class FailedToRunLocalCommand < ::Bcome::Exception::Base
      def message_prefix
        'Failed to run local command: '
      end
    end
  end
end
