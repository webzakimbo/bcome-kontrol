module Bcome::Driver
  class Ec2 < Bcome::Driver::Base

    def fog_client
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
