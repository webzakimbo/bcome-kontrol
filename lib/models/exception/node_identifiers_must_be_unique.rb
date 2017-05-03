module ::Bcome::Exception
  class NodeIdentifiersMustBeUnique < ::Bcome::Exception::Base
    def message_prefix
      'Node names within the same view level must be unique'
    end
  end
end
