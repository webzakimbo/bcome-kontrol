# frozen_string_literal: true

module Bcome
  module Exception
    class CantFindKeyInCloudTags < ::Bcome::Exception::Base
      def message_prefix
        'Cannot find key in cloud tags '
      end
    end
  end
end
