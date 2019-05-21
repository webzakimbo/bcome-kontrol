module Bcome::Oauth
  class GoogleApi

    CREDENTIAL_FILE_SUFFIX = "oauth2.json".freeze

    def initialize(service, scopes, node)
      @service = service
      @scopes = scopes
      @node = node
    end

    def storage
      @storage ||= ::Google::APIClient::Storage.new(Google::APIClient::FileStore.new(credential_file))
    end

    def credential_file
      "#{@node.keyed_namespace}:#{CREDENTIAL_FILE_SUFFIX}"
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
        print "\nAuthenticating with GCP for network namespace #{@node.namespace}. Close browser window once done. A GCP secrets file named '#{credential_file}' will be placed in your project root.".informational
        print "\sDo not commit this file to source control".warning

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
