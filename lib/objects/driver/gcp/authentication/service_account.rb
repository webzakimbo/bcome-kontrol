# frozen_string_literal: true

# TODO - move this into its own file
module Bcome
  class ServiceAccount < Signet::OAuth2::Client

    def initialize(scopes, service_account_json_path)
      @scopes = scopes
      @service_account_json_path = service_account_json_path
    end

    def fetch_access_token(options={})
      token = authorizer.fetch_access_token!
      return token
    end

    def authorize
      @token ||= fetch_access_token
    end

    def authorizer
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(@service_account_json_path),
        scope: @scopes
      )
    end
  end
end

# TODO - add error trapping (missing file, unauthorised etc)
# TODO - add to documentation trello
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
      @service_account ||= ::Bcome::ServiceAccount.new(@scopes, full_path_to_credential_file)
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
