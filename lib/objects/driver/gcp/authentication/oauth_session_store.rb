# frozen_string_literal: true

module Bcome::Driver::Gcp::Authentication
  class OauthSessionStore
    include Singleton

    def initialize
      @oauth_sessions = []
    end

    def in_memory_session_for(oauth_client_config)
      existing_session = @oauth_sessions.detect do |session|
        session.client_config == oauth_client_config
      end
      existing_session
    end

    def <<(session)
      @oauth_sessions << session
    end
  end
end
