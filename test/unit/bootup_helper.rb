module Bcome::Node
  class Base
    def methodthatdoesnotrequirearguments
      'bar'
    end

    def methodthattakesinoneargument(_argument)
      'bar'
    end
  end
end
