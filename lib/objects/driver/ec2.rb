module Bcome::Driver
  class Ec2 < Bcome::Driver::Base
    def initialize(*params)
      super
      raise Bcome::Exception::Ec2DriverMissingProvisioningRegion, params.inspect unless provisioning_region
    end

    def fog_client
      @fog_client ||= get_fog_client
    end

    def fetch_server_list(filters)
      servers = unfiltered_server_list.all(filters)
      servers
    end

    def unfiltered_server_list
      @unfiltered_server_list ||= fog_client.servers.all({})
    end

    def loading
      fog_client.servers.all({})
    end

    def credentials_key
      @params[:credentials_key]
    end

    def provisioning_region
      @params[:provisioning_region]
    end

    protected

    def get_fog_client
      ::Fog.credential = credentials_key
      client = ::Fog::Compute.new(
        provider: 'AWS',
        region: provisioning_region
      )
      client
    end
  end
end
