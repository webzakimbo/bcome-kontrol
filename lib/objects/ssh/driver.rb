# frozen_string_literal: true

# TODO - MULTI-HOP PROXY DETAILS (#pretty_config_details)

module Bcome::Ssh
  class Driver
    attr_reader :config, :bootstrap_settings

    include Bcome::Ssh::DriverConnection
    include Bcome::Ssh::DriverFunctions
    include Bcome::Ssh::DriverUser
    include Bcome::Ssh::DriverCommandStrings

    def initialize(config, context_node)
      @config = config
      @context_node = context_node
    end

    def bastion_host_user
      bootstrap? && @bootstrap_settings.bastion_host_user ? @bootstrap_settings.bastion_host_user : @proxy_data.bastion_host_user || user
    end

    def proxy_data
      @proxy_data ||= set_proxy_data
    end

    def set_proxy_data

      ## TODO
      ### Collapse ProxyData into one object, encapsulating the behaviour that we want

      if has_proxy?
        ::Bcome::Ssh::ProxyData::SingleHop.new(@config[:proxy], @context_node)
      elsif has_multi_hop_proxy?
        ::Bcome::Ssh::ProxyData::MultiHop.new(@config[:multi_hop_proxy], @context_node) 
      else
        nil
      end      
    end


    def pretty_config_details  ### TODO proxy config to come from proxy_data
      config = {
        user: user,
        ssh_keys: ssh_keys,
        timeout: timeout_in_seconds
      }
      if has_proxy?
        config[:host_or_ip] = @context_node.internal_ip_address
        config[:proxy] = {
          bastion_host: @proxy_data.host,
          bastion_host_user: bastion_host_user
        }
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
      !@bootstrap_settings.nil?
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
