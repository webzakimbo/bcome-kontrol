module ::Bcome::Exception
  class InvalidNetworkDriverType < ::Bcome::Exception::Base

    def message_prefix
      "Invalid network driver type"
    end

  end
end
