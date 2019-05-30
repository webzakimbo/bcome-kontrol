# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidMetaDataEncryptionKey < ::Bcome::Exception::Base
      def message_prefix
        'Your metadata encryption key is invalid - your metadata files are encrypted with a different key.'
      end
    end
  end
end
