module Bcome::Registry::Command
  class External < Base

    # In which the bcome context is passed to an external call

    def expected_keys
      super + [:local_command]
    end

  end
end
