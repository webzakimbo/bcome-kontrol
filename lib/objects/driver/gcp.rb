module Bcome::Driver
  class Gcp < Bcome::Driver::Base

    APPLICATION_NAME = "Bcome console".freeze

    def initialize(*params)
      super
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
      # The system already includes a default scope of https://www.googleapis.com/auth/compute.readonly, which is the minimum Bcome needs to list resources.
      # I've included flexibility to add additional scopes to assist with specific orchestrative cases.
      # TODO - document how to define & add additional scopes
      authentication = ::Bcome::Oauth::GoogleApi.new(gcp_service, service_scopes)
      authentication.do!
    end

    def gcp_service
      @gcp_service ||= ::Google::Apis::ComputeBeta::ComputeService.new
    end

    def default_scope
      # The minimum scope Bcome needs in order to function: this allows for the readonly listing of resources
      ["https://www.googleapis.com/auth/compute.readonly"]
    end

    def service_scopes
      client_scopes = has_client_defined_scopes? ? @params[:gcp_service_scopes] : []
      return default_scope + client_scopes
    end

    def has_client_defined_scopes?
      @params[:gcp_service_scopes] && @params[:gcp_service_scopes].is_a?(Array)
    end

  end
end
