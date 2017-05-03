module Bcome::Exception
  class Base < RuntimeError
    def initialize(message_suffix = nil)
      @message_suffix = message_suffix
    end

    def message
      "#{message_prefix}#{@message_suffix ? ": #{@message_suffix}" : ''}"
    end
  end
end