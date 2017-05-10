module Bcome::Interactive::SessionItem
  class Base

    def initialize(session)
      @session = session
    end

    def bcome_identifier  
      node.namespace
    end

    def node
      @session.node
    end

    def options
      @session.options
    end

    def set_response_on_session
      @session.responses[@key] = @response
    end

    def do(*params)
      raise "Should be overidden"
    end

  end
end
