# frozen_string_literal: true

module Bcome
  module Exception
    class MissingTypeOnView < ::Bcome::Exception::Base
      def message_prefix
        'One of your views is missing a type field'
      end
    end
  end
end
