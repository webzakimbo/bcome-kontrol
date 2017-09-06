module Bcome::Ssh
  class ProxyData
    def initialize(config, context_node)
      @config = config
      @context_node = context_node
    end

    def host
      @host ||= get_host
    end

    def bastion_host_user
      @bastion_host_user ||= get_bastion_host_user
    end

    private

    def valid_host_lookups
      {
        by_inventory_node: :get_host_by_inventory_node, 
        by_host_or_ip: :get_host_or_ip_from_config,
        by_bcome_namespace: :get_host_by_namespace
      }
    end

    def get_bastion_host_user
      @config[:bastion_host_user]
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
