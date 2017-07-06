module Bcome::Node
  module Extensions

   def correct_number_of_arguments_supplied_to_method?(method_name, number_of_arguments)
     return (number_of_arguments == method_signature_arity(method_name))
    end

    def method_signature_arity(method_name)
      instance_method(method_name).arity
    end

  end
end
