# frozen_string_literal: true

module Bcome
  module Exception
    class MissingNetworkConfig < ::Bcome::Exception::Base
      def message_prefix
        'Cannot find network config at'
      end
    end
  end
end
