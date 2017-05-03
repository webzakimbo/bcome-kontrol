module ::Bcome::Exception
  class MissingEstateConfig < ::Bcome::Exception::Base

    def message_prefix
      "Cannot find estate config at"
    end

  end
end
