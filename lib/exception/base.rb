module Bcome::Exception
  class Base < RuntimeError

    def initialize(params = nil)
      @params = params
    end

    def message
      "#{message_prefix}: #{@params.inspect}"
    end

  end
end
