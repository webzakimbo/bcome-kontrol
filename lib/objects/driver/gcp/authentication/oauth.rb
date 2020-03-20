# frozen_string_literal: true

require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'google/api_client/client_secrets'

module Bcome::Driver::Gcp::Authentication
  class Oauth < Base
    credential_directory = '.gauth'

    def initialize(driver, service, scopes, node, path_to_secrets)
      @service = service
      @scopes = scopes
      @node = node
      @driver = driver

      @path_to_secrets = "#{credential_directory}/#{path_to_secrets}"
      # All credentials are held in .gauth
      ensure_credential_directory
    end

    def authorized?
      storage && !@storage.authorization.nil?
    end

    def storage
      @storage ||= ::Google::APIClient::Storage.new(Google::APIClient::FileStore.new(full_path_to_credential_file))
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
