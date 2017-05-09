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
        by_host_or_ip: :get_host_or_ip_from_config
      }
    end
 
    def get_bastion_host_user
      @config[:bastion_host_user]
    end

    def get_host
      raise ::Bcome::Exception::InvalidProxyConfig.new("Missing host id") unless @config[:host_id]
      raise ::Bcome::Exception::InvalidProxyConfig.new("Missing host lookup method") unless @config[:host_lookup]
      host_lookup_method = valid_host_lookups[@config[:host_lookup].to_sym]
      raise ::Bcome::Exception::InvalidProxyConfig.new("#{@config[:host_lookup]} is not a valid host lookup method") unless host_lookup_method
      return send(host_lookup_method)
    end

    def get_host_or_ip_from_config
      @config[:host_id]
    end

    def get_host_by_inventory_node
      identifier = @config[:host_id]
      resource = @context_node.recurse_resource_for_identifier(identifier)
      raise ::Bcome::Exception::CantFindProxyHostByIdentifier.new(identifier) unless resource
      raise ::Bcome::Exception::ProxyHostNodeDoesNotHavePublicIp.new(identifier) unless resource.public_ip_address
      return resource.public_ip_address 
    end

  end
end
