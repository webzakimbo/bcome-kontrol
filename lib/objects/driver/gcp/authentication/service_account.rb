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
      @service_account ||= ::Bcome::Driver::Gcp::Authentication::SignetServiceAccountClient.new(@scopes, full_path_to_credential_file)
    end

    def ensure_credentials_file
      raise ::Bcome::Exception::MissingGcpServiceAccountCredentialsFilename unless @credentials_file_name
    end  
  
    def full_path_to_credential_file
      "#{credential_directory}/#{@credentials_file_name}"
    end

    def authorize!
      storage.authorize
      @service.authorization = storage.authorization
    end
 
  end
end
