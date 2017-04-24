module Bcome::Driver
  class Base

    class << self
      def create_from_config(config)
        driver_klass = klass_for_type[config["type"]]
        raise ::Bcome::Exception::InvalidNetworkDriverType.new unless driver_klass
        driver = driver_klass.new(config)
        return driver 
      end

      def klass_for_type
        {
          "static" => ::Bcome::Driver::Static,
          "ec2" => ::Bcome::Driver::Ec2
        }
      end
    end

    def initialize(params)
      @params = params
    end

  end
end
