module Bcome::Exception
  class FailedToRunLocalCommand < ::Bcome::Exception::Base
    def message_prefix
      'Failed to run local command: '
    end
  end
end
