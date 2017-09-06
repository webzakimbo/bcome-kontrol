module ::Bcome::Exception
  class CannotFindInternalRegistryKlass < ::Bcome::Exception::Base
    def message_prefix
      'Could not initialize orchestration method '
    end
  end
end
