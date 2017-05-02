module ::Bcome::Exception
  class MethodInvocationRequiresParameter < ::Bcome::Exception::Base

    def message_prefix
      "Method invocation requires parameter: "
    end

  end
end
