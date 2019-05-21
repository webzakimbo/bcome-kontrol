module Bcome::Driver
  class Gcp < Bcome::Driver::Base

    APPLICATION_NAME = "Bcome console".freeze

    def initialize(*params)
      super
      validate_service_scopes
    end

    def fetch_server_list(filters)
      begin
        instances = gcp_compute_service.list_instances(@params[:project], @params[:zone])
      rescue Google::Apis::AuthorizationError
        raise ::Bcome::Exception::CannotAuthenticateToGcp.new 
      end
    
      instances.items
    end

    def gcp_compute_service
      @gcp_compute_service ||= get_gcp_compute_service
    end  

    protected

    def get_gcp_compute_service
      gcp_compute_authenticate!
      gcp_service
    end

    def gcp_compute_authenticate!
      # Service scopes are now specified directly from the network config
      # A minumum scope of https://www.googleapis.com/auth/compute.readonly is required in order to list resources.
      authentication = ::Bcome::Oauth::GoogleApi.new(gcp_service, service_scopes, @node)
      authentication.do!
    end

    def gcp_service
      @gcp_service ||= ::Google::Apis::ComputeBeta::ComputeService.new
    end

    def service_scopes
      @params[:service_scopes]
    end

    def validate_service_scopes
      raise ::Bcome::Exception::MissingGcpServiceScopes.new "Missing gcp service scopes. Please define as minimum https://www.googleapis.com/auth/compute.readonly" unless has_service_scopes_defined?
    end
 
    def has_service_scopes_defined?
      service_scopes && service_scopes.any?
    end
 
  end
end
