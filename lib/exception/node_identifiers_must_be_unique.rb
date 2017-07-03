module ::Bcome::Exception
  class NodeIdentifiersMustBeUnique < ::Bcome::Exception::Base
    def message_prefix
      'Node identifiers cannot be ambiguous: '
    end
  end
end
