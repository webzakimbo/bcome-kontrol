# frozen_string_literal: true

module Bcome::Ssh
  class ProxyHop

    attr_reader :parent

    def initialize(config, context_node, parent)
      @config = config
      @context_node = context_node
      @parent = parent
    end

    def host
      @host ||= get_host
    end

    def user
      @user ||= get_user
    end

    def has_parent?
      !parent.nil?
    end

    def get_ssh_string
      con_str = "ProxyCommand ssh -W %h:%p\s"

      if has_parent?
        con_str += "-o\s\\\"#{parent.get_ssh_string}\\\"\s"
      end

      con_str += "#{user}@#{host}"
      con_str
    end

    def get_connection_string
      con_str = has_parent? ? "\"ProxyCommand ssh -W %h:%p" : ""
      
      if has_parent?
        con_str += "\s#{parent.get_connection_string}\s"
      end
      
      con_str += "#{user}@#{host}"
      con_str += "\"" unless has_parent?

      con_str
    end


    private

    def valid_host_lookups
      {
        by_inventory_node: :get_host_by_inventory_node,
        by_host_or_ip: :get_host_or_ip_from_config,
        by_bcome_namespace: :get_host_by_namespace
      }
    end

    def get_user
      @config[:bastion_host_user] || @config[:fallback_bastion_host_user]
    end

    def get_host
      raise Bcome::Exception::InvalidProxyConfig, 'Missing host id or namespace' unless @config[:host_id] || @config[:namespace]
      raise Bcome::Exception::InvalidProxyConfig, 'Missing host lookup method' unless @config[:host_lookup]

      host_lookup_method = valid_host_lookups[@config[:host_lookup].to_sym]
      raise Bcome::Exception::InvalidProxyConfig, "#{@config[:host_lookup]} is not a valid host lookup method" unless host_lookup_method

      send(host_lookup_method)
    end

    def get_host_or_ip_from_config
      @config[:host_id]
    end

    def get_host_by_inventory_node
      identifier = @config[:host_id]
      resource = @context_node.recurse_resource_for_identifier(identifier)
      raise Bcome::Exception::CantFindProxyHostByIdentifier, identifier unless resource
      raise Bcome::Exception::ProxyHostNodeDoesNotHavePublicIp, identifier unless resource.public_ip_address

      resource.public_ip_address
    end

    def get_host_by_namespace
      node = ::Bcome::Orchestrator.instance.get(@config[:namespace])
      raise Bcome::Exception::CantFindProxyHostByNamespace, @config[:namespace] unless node

      node.public_ip_address
    end
  end
end
