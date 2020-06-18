# frozen_string_literal: true

module Bcome::Driver::Gcp::Authentication
  class ServiceAccount < Base
    def initialize(service, scopes, node, credentials_file_name, driver)
      @service = service
      @scopes = scopes
      @node = node
      @driver = driver
      @credentials_file_name = credentials_file_name
      ensure_credential_directory
      ensure_credentials_file
    end

    def do!
      @service.authorization = service_account
    end

    def authorized?
      !@service.authorization.nil?
    end

    def service_account
      @service_account ||= ::Bcome::Driver::Gcp::Authentication::SignetServiceAccountClient.new(@scopes, credentials_file_path)
    end

    def credentials_file_path
      has_namespaced_keyed_filename? ? namespaced_keyed_filename : defined_credentials_files
    end

    def ensure_credentials_file
      return if has_namespaced_keyed_filename?
      raise ::Bcome::Exception::MissingGcpServiceAccountCredentialsFilename unless @credentials_file_name
    end

    ## New implementation - we take a defined file name for the service account credentials
    ## Clean & may be re-used
    def defined_credentials_files
      "#{credential_directory}/#{@credentials_file_name}"
    end

    def has_namespaced_keyed_filename?
      @has_namespaced_keyed_filename ||= File.exist?(namespaced_keyed_filename)
    end

    ## Older implementation - we infer the credentials file from the namespace
    ## Retained to provide backwards compatibility
    def namespaced_keyed_filename
      full_path_to_credential_file
    end

    def credential_file_suffix
      'service-account.json'
    end
    #######################################

    def authorize!
      storage.authorize
      @service.authorization = storage.authorization
    end
  end
end
