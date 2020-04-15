# frozen_string_literal: true
module Bcome::Driver::Gcp::Authentication
  class ServiceAccount < Base

    def initialize(service, scopes, node, driver)
      @service = service
      @scopes = scopes
      @node = node
      @driver = driver
      ensure_credential_directory
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

    def credential_file_suffix
      'service-account.json'
    end

    def authorize!
      storage.authorize
      @service.authorization = storage.authorization
    end
 
  end
end
