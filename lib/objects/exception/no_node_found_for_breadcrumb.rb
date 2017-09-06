module ::Bcome::Exception
  class NoNodeFoundForBreadcrumb < ::Bcome::Exception::Base
    def message_prefix
      'No node exists for breadcrumb'
    end
  end
end
