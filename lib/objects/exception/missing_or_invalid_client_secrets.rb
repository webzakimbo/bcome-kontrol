module ::Bcome::Exception
  class MissingOrInvalidClientSecrets < ::Bcome::Exception::Base
    def message_prefix
      "Missing or invalid client secrets file\s"
    end
  end
end
