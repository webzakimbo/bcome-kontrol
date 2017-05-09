module Bcome::Ssh
  class Driver

    # TODO - we're going to fallback to .bcomerc data if present
    # we'll handle this in our data loader and merge it in lower down

    # TODO - test this class

    def initialize(config, context_node)
      @config = config
      @context_node = context_node
      @proxy_data = @config[:proxy] ? ::Bcome::Ssh::ProxyData.new(@config[:proxy], @context_node) : nil
    end

    def proxy
      return nil unless has_proxy?
      return ::Net::SSH::Proxy::Command.new("ssh -o StrictHostKeyChecking=no -W %h:%p #{bastion_host_user}@#{@proxy_data.host}")  
    end

    def bastion_host_user
      @proxy_data.bastion_host_user ? @proxy_data.bastion_host_user : @context_node.ssh_user
    end  

    def has_proxy?
      @config[:proxy]
    end
    
    def do_ssh
      if has_proxy?
        command = "ssh -o UserKnownHostsFile=/dev/null -o \"ProxyCommand ssh -W %h:%p #{bastion_host_user}@#{@proxy_data.host}\" #{@context_node.ssh_user}@#{@context_node.internal_interface_address}"
      else
        command = "ssh #{@context_node.ssh_user}@#{@context_node.public_ip_address}"
      end     
      @context_node.execute_local(command)
    end

    def user
      config_user ? config_user : fallback_local_user
    end

    def config_user
      @config[:user]
    end

    def fallback_local_user
      ::Bcome::System::Local.instance.local_user
    end

  end
end
