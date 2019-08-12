# frozen_string_literal: true
module Bcome::Ssh
  class ConnectionWrangler

    PROXY_SSH_PREFIX = '-o UserKnownHostsFile=/dev/null -o "ProxyCommand ssh -W %h:%p'

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

    def get_ssh_command(config = {}, proxy_only = false)
      cmd  = config[:as_pseudo_tty] ? "ssh -t" : "ssh"
      cmd += "\s-o\s" +  "\"#{first_hop.get_ssh_string}\"" if has_hop? 
      cmd += "\s#{@ssh_driver.node_level_ssh_key_connection_string}#{@ssh_driver.user}@#{target_machine_ingress_ip}" unless proxy_only
      return cmd 
    end

    def get_proxy_connection
      proxy_prefix = "ssh -W %h:%p"

      if single_hop?
        cmd = "#{proxy_prefix} #{first_hop.user}@#{first_hop.host}"
      else
        cmd = "#{proxy_prefix} -o\s" 
        cmd += first_hop.get_connection_string
      end

      return cmd 
    end

    # rsync -av -e "ssh -A guillaume@146.148.115.179 ssh -o StrictHostKeyChecking=no" config_mgmt/ guillaume@10.0.0.10:/home/guillaume
    def get_rsync_command(local_path, remote_path)
      cmd = "rsync -av -e\s"
      cmd += "\""
         
      cmd += first_hop.get_rsync_string

      cmd += "\sssh -o StrictHostKeyChecking=no\""
      cmd += "\s#{local_path}\s#{@ssh_driver.user}@#{target_machine_ingress_ip}:#{remote_path}"
      cmd
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
      iterable_configs.reverse.each do |config|
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
