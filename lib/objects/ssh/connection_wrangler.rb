# frozen_string_literal: true

require 'net/ssh/proxy/jump'

module Bcome::Ssh
  class ConnectionWrangler

    def initialize(ssh_driver)
      @ssh_driver = ssh_driver
      @config = ssh_driver.config[:proxy]
      @context_node = ssh_driver.context_node
      @user = ssh_driver.user
    end

    ## Accessors --

    def proxy_details
      return hops.reverse.collect{ |hop|
        hop.proxy_details
      }
    end
 
    def first_hop
      hops.reverse.first
    end

    def has_hop?
      hops.any?
    end

    def single_hop?
      has_hop? && hops.size == 1
    end

    def proxy
      @proxy ||= create_proxy
    end

    def create_proxy
      proxy = Net::SSH::Proxy::Jump.new(hops.reverse.collect(&:get_ssh_string).join(","))
      return proxy
    end

    def get_ssh_command(config = {}, proxy_only = false)
      cmd = has_hop? ? "ssh -J" : "ssh"
      cmd += "\s" + hops.collect(&:get_ssh_string).join(",") if has_hop?
      cmd += "\s#{@ssh_driver.node_level_ssh_key_connection_string}\s#{@ssh_driver.user}@#{target_machine_ingress_ip}"
      return cmd 
    end

    def get_rsync_command(local_path, remote_path)
      cmd = "rsync -azv"
      cmd += "\s-e 'ssh\s-A -J\s" + hops.collect(&:get_ssh_string).join(",") + "'" if has_hop?
      cmd += "\s#{local_path}\s#{@ssh_driver.user}@#{target_machine_ingress_ip}:#{remote_path}"
      return cmd
    end

    def get_local_port_forward_command(start_port, end_port)
      raise ::Bcome::Exception::InvalidPortForwardRequest, "Connections to this node are not via a proxy. Rather than port forward, try connecting directly." unless has_hop?
      cmd = "ssh -N -L\s"
      cmd += "#{start_port}:#{target_machine_ingress_ip}:#{end_port}\s"
      cmd += "\s" + hops.reverse.collect(&:get_ssh_string).join("\s") if has_hop?
      return cmd
    end

    protected

    def target_machine_ingress_ip
      has_hop? ? @context_node.internal_ip_address : @context_node.public_ip_address
    end
 
    def hops
      @hops ||= set_hops
    end

    private    

    def set_hops
      hop_collection = []

      parent = nil
      iterable_configs.each do |config|
        hop = set_proxy_hop(config, parent)
        hop_collection << hop
        parent = hop
      end

      return hop_collection
    end

    def set_proxy_hop(config, parent)
      config[:fallback_bastion_host_user] = @ssh_driver.fallback_bastion_host_user
      ::Bcome::Ssh::ProxyHop.new(config, @context_node, parent)
    end

    def iterable_configs
      @iterable ||=  @config ? (@config.is_a?(Hash) ? [@config] : @config) : []
    end

  end
end
