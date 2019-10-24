# frozen_string_literal: true

module Bcome
  module Exception
    class MissingOrInvalidClientSecrets < ::Bcome::Exception::Base
      def message_prefix
        "Missing or invalid client secrets file\s"
      end
    end
  end
end
