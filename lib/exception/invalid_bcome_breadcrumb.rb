module ::Bcome::Exception
  class InvalidBcomeBreadcrumb < ::Bcome::Exception::Base

    def message_prefix
      "Invalid bcome breadcrumb"
    end

  end
end
