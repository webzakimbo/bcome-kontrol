# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidMetaDataEncryptionKey < ::Bcome::Exception::Base
      def message_prefix
        'Your metadata encryption key is invalid.'
      end
    end
  end
end
