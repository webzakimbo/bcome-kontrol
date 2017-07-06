module Bcome::Node
  module Extensions

   def method_is_appropriate_for_command_line_invocation(method_name, number_of_arguments)
      return (number_of_arguments == method_signature_arity(method_name))
    end

    def method_signature_arity(method_name)
      instance_method(method_name).arity
    end

  end
end
