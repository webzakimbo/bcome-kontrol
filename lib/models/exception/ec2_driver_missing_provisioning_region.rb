module ::Bcome::Exception
  class Ec2DriverMissingProvisioningRegion < ::Bcome::Exception::Base
    def message_prefix
      'Missing provisioning region for network data: '
    end
  end
end
