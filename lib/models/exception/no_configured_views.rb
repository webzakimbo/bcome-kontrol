module ::Bcome::Exception
  class NoConfiguredViews < ::Bcome::Exception::Base

    def message_prefix
      "You do not have any configured views"
    end

  end
end
