# frozen_string_literal: true

module Bcome::Driver::Gcp::Authentication
  class Oauth
    CREDENTIAL_DIRECTORY = '.gauth'
    CREDENTIAL_FILE_SUFFIX = 'oauth2.json'

    def initialize(service, scopes, node, path_to_secrets)
      @service = service
      @scopes = scopes
      @node = node
      @path_to_secrets = "#{CREDENTIAL_DIRECTORY}/#{path_to_secrets}"
      # All credentials are held in .gauth
      ensure_credential_directory
    end

    def storage
      @storage ||= ::Google::APIClient::Storage.new(Google::APIClient::FileStore.new(full_path_to_credential_file))
    end

    def full_path_to_credential_file
      "#{CREDENTIAL_DIRECTORY}/#{credential_file}"
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
      ::Google::APIClient::ClientSecrets.load(@path_to_secrets)
    rescue Exception => e
      raise ::Bcome::Exception::MissingOrInvalidClientSecrets, "#{@path_to_secrets}. Gcp exception: #{e.class} #{e.message}"
    end

    def do!
      authorize!
      if @storage.authorization.nil?
        print "\nAuthenticating with GCP for network namespace #{@node.namespace}. Close browser window once done. A GCP secrets file named '#{credential_file}' will be placed in your project root.".informational
        print "\sDo not commit this file to source control\n".warning

        flow = Google::APIClient::InstalledAppFlow.new(
          client_id: client_secrets.client_id,
          client_secret: client_secrets.client_secret,
          scope: @scopes
        )
        begin
          @service.authorization = flow.authorize(storage)
        rescue ArgumentError => e
          raise ::Bcome::Exception::MissingOrInvalidClientSecrets, "#{@path_to_secrets}. Gcp exception: #{e.class} #{e.message}"
        end

      end
      @service
    end

    def ensure_credential_directory
      FileUtils.mkdir_p CREDENTIAL_DIRECTORY
    end
  end
end
