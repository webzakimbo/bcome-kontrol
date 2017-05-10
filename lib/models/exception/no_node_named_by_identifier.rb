module Bcome::Exception
  class NoNodeNamedByIdentifier < ::Bcome::Exception::Base
    def message_prefix
      "Cannot find identifier within inventory"
    end
  end
end
