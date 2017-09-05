module ::Bcome::Exception
  class CannotFindSubselectionParent < ::Bcome::Exception::Base
    def message_prefix
      "Cannot find subselection parent"
    end
  end
end
