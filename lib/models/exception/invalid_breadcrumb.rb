module ::Bcome::Exception
  class InvalidBreadcrumb < ::Bcome::Exception::Base

    def message_prefix
      "Invalid breadcrumb: "
    end

  end
end
