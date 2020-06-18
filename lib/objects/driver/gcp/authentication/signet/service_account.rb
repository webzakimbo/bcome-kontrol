# frozen_string_literal: true

module Bcome::Driver::Gcp::Authentication
  class SignetServiceAccountClient < Signet::OAuth2::Client
    def initialize(scopes, service_account_json_path)
      @scopes = scopes
      @service_account_json_path = service_account_json_path
      raise ::Bcome::Exception::GcpAuthServiceAccountMissingCredentials, @service_account_json_path unless File.exist?(@service_account_json_path)
    end

    def fetch_access_token(_options = {})
      token = authorizer.fetch_access_token!
      token
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
