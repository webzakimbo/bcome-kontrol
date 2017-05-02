module Bcome::Exception
  class MissingTypeOnView < ::Bcome::Exception::Base

    def message_prefix
      "One of your views is missing a type field"
    end
 
  end
end
