module ::Bcome::Exception
  class CantFindKeyInMetadata < ::Bcome::Exception::Base
    def message_prefix
      'Cannot find key in bcome metadata '
    end
  end
end
