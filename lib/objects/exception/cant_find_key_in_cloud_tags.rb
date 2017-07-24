module ::Bcome::Exception
  class CantFindKeyInCloudTags < ::Bcome::Exception::Base
    def message_prefix
      'Cannot find key in cloud tags '
    end
  end
end
