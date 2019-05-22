module Bcome::Driver
  class Gcp < Bcome::Driver::Base

    APPLICATION_NAME = "Bcome console".freeze

    def initialize(*params)
      super
      validate_service_scopes
      validate_authentication_scheme
    end

    def fetch_server_list(filters)
      begin
        instances = gcp_compute_service.list_instances(@params[:project], @params[:zone])
      rescue Google::Apis::AuthorizationError
        raise ::Bcome::Exception::CannotAuthenticateToGcp.new 
      rescue Google::Apis::ClientError => e
        raise ::Bcome::Exception::Generic, "Namespace #{@node.namespace} / #{e.message}"
      end
    
      instances.items
    end

    def gcp_compute_service
      @gcp_compute_service ||= get_gcp_compute_service
    end  

    protected

    def validate_authentication_scheme
      raise ::Bcome::Exception::MissingGcpAuthenticationScheme.new "node #{@node.namespace}" if @params[:authentication_scheme].nil? || @params[:authentication_scheme].empty?
      raise ::Bcome::Exception::InvalidGcpAuthenticationScheme.new "Invalid GCP authentication scheme '#{@params[:authentication_scheme]}' for node #{@node.namespace}" unless auth_scheme
    end

    def invalid_auth_scheme?
      !auth_schemes.keys.include?(@params[:authentication_scheme].to_sym)
    end

    def auth_scheme
      auth_schemes[@params[:authentication_scheme].to_sym]
    end

    def auth_schemes
      {
        :oauth => :gcp_authenticate_via_oauth, 
        :serviceaccount => :gcp_authenticate_via_service_account
      }
    end 

    def get_gcp_compute_service
      send(auth_scheme)
      gcp_service
    end

    def gcp_authenticate_via_service_account
      ## TODO - placeholder for service account authentication
      gcp_service
    end

    def gcp_authenticate_via_oauth
      # Service scopes are now specified directly from the network config
      # A minumum scope of https://www.googleapis.com/auth/compute.readonly is required in order to list resources.
      authentication = ::Bcome::Oauth::GoogleApi.new(gcp_service, service_scopes, @node, @params[:secrets_path])
      authentication.do!
    end

    def gcp_service
      @gcp_service ||= ::Google::Apis::ComputeBeta::ComputeService.new
    end

    def service_scopes
      @params[:service_scopes]
    end

    def validate_service_scopes
      raise ::Bcome::Exception::MissingGcpServiceScopes.new "Please define as minimum https://www.googleapis.com/auth/compute.readonly" unless has_service_scopes_defined?
    end
 
    def has_service_scopes_defined?
      service_scopes && service_scopes.any?
    end
 
  end
end
