# frozen_string_literal: true

module Bcome
  module Exception
    class Base < RuntimeError
      def initialize(message_suffix = nil)
        @message_suffix = message_suffix
      end

      def message
        "#{message_prefix}#{@message_suffix ? ": #{@message_suffix}" : ''}"
      end

      def pretty_display
        puts "\n\n#{message}\n".error
      end
    end
  end
end
