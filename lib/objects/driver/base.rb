# frozen_string_literal: true

module Bcome::Driver
  class Base
    class << self
      def create_from_config(config, node)
        raise Bcome::Exception::InvalidNetworkDriverType, 'Your network configurtion is invalid' unless config.is_a?(Hash)
        raise Bcome::Exception::InvalidNetworkDriverType, "Missing config parameter 'type'" unless config[:type]

        config_klass_key = config[:type].to_sym
        driver_klass = klass_for_type[config_klass_key]
        raise Bcome::Exception::InvalidNetworkDriverType, config unless driver_klass

        driver = driver_klass.new(config, node)
        driver
      end

      def klass_for_type
        {
          static: ::Bcome::Driver::Static,
          ec2: ::Bcome::Driver::Ec2,
          gcp: ::Bcome::Driver::Gcp
        }
      end
    end

    def initialize(params, node)
      @params = params
      @node = node
    end

    def config
      @params
    end
  end
end
