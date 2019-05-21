module Bcome::Oauth
  class GoogleApi

    CREDENTIAL_FILE_SUFFIX = "oauth2.json".freeze

    def initialize(service, scopes, node, path_to_secrets)
      @service = service
      @scopes = scopes
      @node = node
      @path_to_secrets = path_to_secrets
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
      @client_secrets ||= load_client_secrets
    end

    def load_client_secrets
      begin
        ::Google::APIClient::ClientSecrets.load(@path_to_secrets)
      rescue Exception
        raise ::Bcome::Exception::MissingOrInvalidClientSecrets, "#{@path_to_secrets}. Gcp exception: #{e.class} #{e.message}"
      end
    end

    def do!
      authorize!
      if @storage.authorization.nil?
        print "\nAuthenticating with GCP for network namespace #{@node.namespace}. Close browser window once done. A GCP secrets file named '#{credential_file}' will be placed in your project root.".informational
        print "\sDo not commit this file to source control\n".warning

        flow = Google::APIClient::InstalledAppFlow.new(
          :client_id => client_secrets.client_id,
          :client_secret => client_secrets.client_secret,
          :scope => @scopes
        )
        begin
          @service.authorization = flow.authorize(storage)
        rescue ArgumentError => e 
          raise ::Bcome::Exception::MissingOrInvalidClientSecrets, "#{@path_to_secrets}. Gcp exception: #{e.class} #{e.message}"
        end

      end
      return @service
    end

  end
end
