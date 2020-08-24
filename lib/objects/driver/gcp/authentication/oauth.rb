# frozen_string_literal: true

require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'google/api_client/client_secrets'

module Bcome::Driver::Gcp::Authentication
  class Oauth < Base
    credential_directory = '.gauth'

    attr_reader :scopes, :secrets_filename, :service, :client_config

    def initialize(driver, service, client_config, node)
      @service = service
      @scopes = client_config.scopes
      @node = node
      @driver = driver
      @client_config = client_config
      @secrets_filename = client_config.secrets_filename
      @path_to_secrets = "#{credential_directory}/#{@secrets_filename}"

      raise ::Bcome::Exception::Generic, 'Missing Oauth client secrets file from GCP network configuration. Please ensure you have set the secrets_path attribute.' unless File.exist?(@path_to_secrets) && File.file?(@path_to_secrets)

      # All credentials are held in .gauth
      ensure_credential_directory
    end

    def authorized?
      storage && !@storage.authorization.nil?
    end

    def credential_file_suffix
      'oauth2.json'
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

    def storage
      @storage ||= ::Google::APIClient::Storage.new(Google::APIClient::FileStore.new(full_path_to_credential_file))
    end

    def credential_file
      # If an authorization has the same scopes & secrets file, it is the same authorization. Hence we store the resulting oauth2 access credentials as the same file. This allows
      # re-use of authorizations and prevents multiple oauth loops.
      "#{@client_config.checksum}:#{credential_file_suffix}"
    end

    def do!
      authorize!
      if @storage.authorization.nil?
        # Total bloat from google here. Thanks google... requiring at last possible moment.
        require 'google/api_client/auth/installed_app'

        wrap_indicator type: :basic, title: loader_title, completed_title: '' do
          flow = Google::APIClient::InstalledAppFlow.new(
            client_id: client_secrets.client_id,
            client_secret: client_secrets.client_secret,
            scope: @scopes
          )
          begin
             @service.authorization = flow.authorize(storage)
             signal_success
          rescue ArgumentError => e
            signal_failure
            raise ::Bcome::Exception::MissingOrInvalidClientSecrets, "#{@path_to_secrets}. Gcp exception: #{e.class} #{e.message}"
           end
        end
      end

      @service
    end

    def notify_success
      print "[\s" + "Credentials file written to\s" + full_path_to_credential_file + "\s]" + "\n"
    end
  end
end
