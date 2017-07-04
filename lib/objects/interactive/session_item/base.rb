module Bcome::Interactive::SessionItem
  class Base

    def initialize(session, init_data)
      @session = session
      @init_data = init_data
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

    def do(*_params)
      raise 'Should be overidden'
    end

    def get_input(message = terminal_prompt)
      ::Readline.readline("\n#{message}", true).squeeze('').to_s
    end

  end
end
