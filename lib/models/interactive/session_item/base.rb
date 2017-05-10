module Bcome::Interactive::SessionItem
  class Base

    def initialize(session)
      @session = session
      @irb_session = @session.irb_session
    end

    def bcome_identifier  
      @irb_session.become_identifier
    end

    def irb_session
      @session.irb_session
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
