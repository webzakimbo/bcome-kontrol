module ::Bcome::Exception
  class InvalidMetaDataConfig < ::Bcome::Exception::Base
    def message_prefix
      'Invalid meta data config in metadata file '
    end
  end
end
