# frozen_string_literal: true

module Bcome
  module Exception
    class MissingIdentifierOnView < ::Bcome::Exception::Base
      def message_prefix
        'One of your views is missing an identifier field'
      end
    end
  end
end
