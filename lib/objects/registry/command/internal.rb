module Bcome::Registry::Command
  class Internal < Base
    # In which the bcome context is passed to an external call

    def expected_keys
      super + [:orch_klass]
    end
  end
end
