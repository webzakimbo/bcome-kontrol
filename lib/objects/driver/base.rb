# frozen_string_literal: true

module Bcome::Driver
  class Base
    class << self
      def create_from_config(config, node)
        raise Bcome::Exception::InvalidNetworkDriverType, 'Your network configurtion is invalid' unless config.is_a?(Hash)
        raise Bcome::Exception::InvalidNetworkDriverType, "Missing config parameter 'type' for namespace '#{config.inspect}'" unless config[:type]

        config_klass_key = config[:type].to_sym
        driver_klass = klass_for_type[config_klass_key]
        raise Bcome::Exception::InvalidNetworkDriverType, config unless driver_klass

        driver = driver_klass.new(config, node)
        driver
      end

      def klass_for_type
        {
          ec2: ::Bcome::Driver::Ec2,
          gcp: ::Bcome::Driver::Gcp
        }
      end
    end

    include ::Bcome::LoadingBar::Handler

    def spoof_fetch_server_list(monkey_patched_inventory)
      unless @node.nodes_loaded?
        wrap_indicator type: :basic, title: loader_title, completed_title: loader_completed_title do
          fake_delay_milliseconds = rand(1..400).to_f / 1000
          sleep fake_delay_milliseconds
          monkey_patched_inventory.set_static_servers
         signal_success
        end
        @node.nodes_loaded!
      else
        monkey_patched_inventory.set_static_servers
      end
    end

    def initialize(params, node)
      @params = params
      @node = node
    end

    def has_network_credentials?
      false
    end

    def loader_title
      'Loading' + "\s#{pretty_provider_name.bc_blue.bold}\s#{pretty_resource_location.underline}".bc_green
    end

    def loader_completed_title
      'done'
    end

    def pretty_provider_name
      raise 'Should be overriden'
    end

    def pretty_resource_location
      raise 'Should be overidden'
    end

    def network_credentials
      raise 'Should be overidden'
    end

    def config
      @params
    end
  end
end
