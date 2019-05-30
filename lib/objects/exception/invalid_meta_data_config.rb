# frozen_string_literal: true

module Bcome
  module Exception
    class InvalidMetaDataConfig < ::Bcome::Exception::Base
      def message_prefix
        'Invalid meta data config in metadata file '
      end
    end
  end
end
