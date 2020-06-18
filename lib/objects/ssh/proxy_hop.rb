# frozen_string_literal: true

module Bcome::Ssh
  class ProxyHop
    attr_reader :parent

    def initialize(config, context_node, parent)
      @config = config
      @context_node = context_node
      @parent = parent
      set_host
    end

    def proxy_details
      @config.merge(
        proxy_host: host,
        user: user
      ).except!(:bastion_host_user, :fallback_bastion_host_user)
    end

    def host
      @host 
    end

    def user
      @user ||= get_user
    end

    def has_parent?
      !parent.nil?
    end

    def get_ssh_string(_is_first_hop = false)
      con_str = "#{user}@#{host}"
      con_str
    end

    def get_rsync_string
      con_str = ''

      con_str += "#{parent.get_rsync_string}\s" if has_parent?

      con_str += "'ssh -o \"ProxyCommand ssh -A #{user}@#{host} -W %h:%p\"'"
      con_str
    end

    def get_local_port_forward_string
      con_str = ''

      con_str += parent.get_local_port_forward_string.to_s if has_parent?

      con_str += "#{user}@#{host}\s"
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
      # If an explicit user has been set for this hop, use it.
      return @config[:bastion_host_user] if @config[:bastion_host_user]

      # Otherwise, if our proxy hop is a defined bcome server, i.e. it exists in the network map, we can infer the user and so we'll use that.
      return @bcome_proxy_node.ssh_driver.user if @bcome_proxy_node

      # Otherwise, we'll fallback
      return @config[:fallback_bastion_host_user]
    end

    def set_host
      raise Bcome::Exception::InvalidProxyConfig, 'Missing host id or namespace' unless @config[:node_identifier] || @config[:host_id] || @config[:namespace]
      raise Bcome::Exception::InvalidProxyConfig, 'Missing host lookup method' unless @config[:host_lookup]

      host_lookup_method = valid_host_lookups[@config[:host_lookup].to_sym]
      raise Bcome::Exception::InvalidProxyConfig, "#{@config[:host_lookup]} is not a valid host lookup method" unless host_lookup_method

      @host = send(host_lookup_method)
    end

    def get_host_or_ip_from_config
      @config[:host_id]
    end

    # Older lookup - within same parent-child tree only. Retained for backwards compatibility
    def get_host_by_inventory_node
      identifier = @config[:host_id] ? @config[:host_id] : @config[:node_identifier]
      @bcome_proxy_node = @context_node.recurse_resource_for_identifier(identifier)
      raise Bcome::Exception::CantFindProxyHostByIdentifier, identifier unless @bcome_proxy_node
      raise Bcome::Exception::ProxyHostNodeDoesNotHavePublicIp, identifier unless @bcome_proxy_node.public_ip_address

      @bcome_proxy_node.public_ip_address
    end

    # Newer lookup - across entire network
    def get_host_by_namespace
      @bcome_proxy_node = ::Bcome::Orchestrator.instance.get(@config[:namespace])
      raise Bcome::Exception::CantFindProxyHostByNamespace, @config[:namespace] unless @bcome_proxy_node

      @bcome_proxy_node.public_ip_address
    end
  end
end
