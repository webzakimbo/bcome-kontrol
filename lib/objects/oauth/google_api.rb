module Bcome::Oauth
  class GoogleApi

    # TODO - add appropriate exception handling

    # TODO - thought needs to be given to the credentials file. Possibly allow user to specify path, or otherwise we store it in ~/
    # It needs to be out of scope of the application root, in any case.
    CREDENTIAL_STORE_FILE = "#{$0}-oauth2.json"

    def initialize(service, scopes)
      @service = service
      @scopes = scopes
    end

    def storage
      @storage ||= ::Google::APIClient::Storage.new(Google::APIClient::FileStore.new(CREDENTIAL_STORE_FILE))
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
