module Bcome::Exception
  class DeprecationWarning < ::Bcome::Exception::Base

    def message_prefix
      msg = "Your configuration relies on a deprecated version of Bcome, with which version #{::Bcome::VERSION} is not compatible.\n\n"
      msg += "Pin your bcome gem to version 0.7.0, or see our new documentation at https://github.com/webzakimbo/bcome-kontrol for changes"
      msg
    end

  end
end
