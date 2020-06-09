# frozen_string_literal: true

require 'net/scp'

module Bcome::Ssh
  class Driver
    attr_reader :config, :context_node

    include Bcome::Ssh::DriverConnection
    include Bcome::Ssh::DriverFunctions
    include Bcome::Ssh::DriverUser
    include Bcome::Ssh::DriverCommandStrings

    def initialize(config, context_node)
      @config = config
      @context_node = context_node
    end

    def connection_wrangler
      @connection_wrangler ||= set_connection_wrangler
    end

    def set_connection_wrangler
      @set_connection_wrangler ||= ::Bcome::Ssh::ConnectionWrangler.new(self)
    end

    def pretty_ssh_config
      config = {
        user: user,
        timeout: timeout_in_seconds
      }

      if has_proxy?
        config[:proxy] = connection_wrangler.proxy_details
      else
        config[:host_or_ip] = @context_node.public_ip_address
      end

      config
    end

    def proxy_config_value
      @config[:proxy]
    end

    def multi_hop_proxy_config
      @config[:multi_hop_proxy]
    end

    def has_multi_hop_proxy?
      !multi_hop_proxy_config.nil?
    end

    def has_proxy?
      return false if proxy_config_value && proxy_config_value == -1

      !@config[:proxy].nil?
    end
  end
end
