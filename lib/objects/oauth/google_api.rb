module Bcome::Oauth
  class GoogleApi

    CREDENTIAL_FILE = "gcp-oauth2.json".freeze

    def initialize(service, scopes)
      @service = service
      @scopes = scopes
    end

    def storage
      @storage ||= ::Google::APIClient::Storage.new(Google::APIClient::FileStore.new(CREDENTIAL_FILE))
    end

    def authorize!
      @service.authorization = storage.authorize
    end

    def client_secrets
      @client_secrets ||= ::Google::APIClient::ClientSecrets.load
    end

    def do!
      authorize!
      if @storage.authorization.nil?
        flow = Google::APIClient::InstalledAppFlow.new(
          :client_id => client_secrets.client_id,
          :client_secret => client_secrets.client_secret,
          :scope => @scopes
        )
        @service.authorization = flow.authorize(storage)
      end
      return @service
    end

  end
end
