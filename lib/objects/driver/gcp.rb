# frozen_string_literal: true

module Bcome::Driver
  class Gcp < Bcome::Driver::Base
    APPLICATION_NAME = 'Bcome console'

    def initialize(*params)
      super
      validate_service_scopes
      validate_authentication_scheme
    end

    def pretty_provider_name
      "GCP"
    end

    def pretty_resource_location
      "#{@params[:project]}/#{@params[:zone]}"
    end

    def fetch_server_list(_filters)
      start_loader

      begin
        instances = do_fetch_server_list(_filters)
      rescue Exception => e
        signal_failure
        raise e
      end 
 
      signal_stop
      return instances.items
    end

    def do_fetch_server_list(_filters)
      begin
        return gcp_service.list_instances(@params[:project], @params[:zone])
      rescue Google::Apis::AuthorizationError
        raise ::Bcome::Exception::CannotAuthenticateToGcp
      rescue Google::Apis::ClientError => e
        raise ::Bcome::Exception::Generic, "Namespace #{@node.namespace} / #{e.message}"
      rescue Google::Apis::TransmissionError => e
        raise ::Bcome::Exception::Generic, "Cannot reach GCP - do you have an internet connection?"
      end
    end

    def has_network_credentials?
      true
    end

    def network_credentials
      {
        access_token: access_token,
        project_name: @params[:project]
      }
    end

    protected

    def validate_authentication_scheme
      raise ::Bcome::Exception::MissingGcpAuthenticationScheme, "node #{@node.namespace}" if @params[:authentication_scheme].nil? || @params[:authentication_scheme].empty?
      raise ::Bcome::Exception::InvalidGcpAuthenticationScheme, "Invalid GCP authentication scheme '#{@params[:authentication_scheme]}' for node #{@node.namespace}" unless auth_scheme
    end

    def invalid_auth_scheme?
      !auth_schemes.keys.include?(@params[:authentication_scheme].to_sym)
    end

    def auth_scheme
      auth_schemes[@params[:authentication_scheme].to_sym]
    end

    def auth_schemes
      {
        oauth: ::Bcome::Driver::Gcp::Authentication::Oauth,
        serviceaccount: ::Bcome::Driver::Gcp::Authentication::ServiceAccount,
        api_key: ::Bcome::Driver::Gcp::Authentication::ApiKey
      }
    end

    def get_gcp_compute_service
      # Service scopes are now specified directly from the network config
      # A minumum scope of https://www.googleapis.com/auth/compute.readonly is required in order to list resources.
      authentication = auth_scheme.new(gcp_service, service_scopes, @node, @params[:secrets_path])
      authentication.do!
    end

    def gcp_service
      @gcp_service ||= get_authenticated_gcp_service
    end

    def access_token
      gcp_service.authorization.access_token   
    end

    def authorization
      gcp_service.authorization
    end

    def get_authenticated_gcp_service
      service = ::Google::Apis::ComputeBeta::ComputeService.new
      authentication = auth_scheme.new(service, service_scopes, @node, @params[:secrets_path])
      authentication.do!
      service
    end

    def service_scopes
      @params[:service_scopes]
    end

    def validate_service_scopes
      raise ::Bcome::Exception::MissingGcpServiceScopes, 'Please define as minimum https://www.googleapis.com/auth/compute.readonly' unless has_service_scopes_defined?
    end

    def has_service_scopes_defined?
      service_scopes&.any?
    end
  end
end
