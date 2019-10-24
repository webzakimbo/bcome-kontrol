# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidSshConfig < ::Bcome::Exception::Base
      def message_prefix
        'Invalid Ssh Config'
      end
    end
  end
end
