# frozen_string_literal: true

module Bcome::Ssh
  class Driver

    attr_reader :config, :bootstrap_settings, :context_node

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

    def bootstrap_settings
       @bootstrap_settings ||= set_bootstrap_settings
    end

    def set_bootstrap_settings
      return unless has_bootstrap_settings?
      @bootstrap_settings ||= ::Bcome::Ssh::Bootstrap.new(@config[:bootstrap_settings])
    end

    def set_connection_wrangler
      @set_connection_wrangler ||= ::Bcome::Ssh::ConnectionWrangler.new(self)
    end

    def foo
      config = {
        user: user,
        ssh_keys: ssh_keys,
        timeout: timeout_in_seconds
      }

      if has_proxy?
        config[:proxy] = connection_wrangler.proxy_details
      else
        config[:host_or_ip] = @context_node.public_ip_address
      end

      return config
    end

    def proxy_config_value
      @config[:proxy]
    end

    def multi_hop_proxy_config
      @config[:multi_hop_proxy]
    end 

    def node_level_ssh_key_connection_string
      key_specified_at_node_level? ? "-i #{node_level_ssh_key}\s" : ''
    end

    def key_specified_at_node_level?
      !node_level_ssh_key.nil?
    end

    def node_level_ssh_key
      @config[:ssh_keys] ? @config[:ssh_keys].first : nil
    end

    def bootstrap?
      @context_node.bootstrap? && has_bootstrap_settings?
    end

    def has_bootstrap_settings?
      !@config[:bootstrap_settings].nil? 
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
