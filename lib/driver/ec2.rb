module Bcome::Driver
  class Ec2 < Bcome::Driver::Base

    def fog_client
      @fog_client ||= get_fog_client
    end

    def fetch_server_list(filters)
      servers = fog_client.servers.all(filters)
      return servers
    end 

    def filters
      unfiltered_search_params
    end

    protected

    def get_fog_client
      ::Fog.credential = credentials_key
      client = ::Fog::Compute.new(
        :provider => "AWS",
        :region => provisioning_region
      )
      return client
    end

    def credentials_key
      @params["credentials_keys"]
    end

    def credentials_key
      @params["credentials_key"]
    end    

    def provisioning_region
      @params["provisioning_region"]
    end

  end
end
