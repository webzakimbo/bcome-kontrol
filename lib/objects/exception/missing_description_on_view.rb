# frozen_string_literal: true

module Bcome
  module Exception
    class MissingDescriptionOnView < ::Bcome::Exception::Base
      def message_prefix
        'One of your views is missing a description field'
      end
    end
  end
end
