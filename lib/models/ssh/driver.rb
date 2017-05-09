module Bcome::Ssh
  class Driver

    PROXY_CONNECT_PREFIX="ssh -o StrictHostKeyChecking=no -W %h:%p"
    PROXY_SSH_PREFIX="ssh -o UserKnownHostsFile=/dev/null -o \"ProxyCommand ssh -W %h:%p"

    def initialize(config, context_node)
      @config = config
      @context_node = context_node
      @proxy_data = @config[:proxy] ? ::Bcome::Ssh::ProxyData.new(@config[:proxy], @context_node) : nil
    end

    def proxy
      return nil unless has_proxy?
      return ::Net::SSH::Proxy::Command.new(proxy_connection_string)
    end

    def bastion_host_user
      @proxy_data.bastion_host_user ? @proxy_data.bastion_host_user : user
    end  

    def has_proxy?
      !@config[:proxy].nil?
    end
   
    def proxy_connection_string
      "#{PROXY_CONNECT_PREFIX} #{bastion_host_user}@#{@proxy_data.host}"
    end
  
    def do_ssh
      if has_proxy?
        command = "#{PROXY_SSH_PREFIX} #{bastion_host_user}@#{@proxy_data.host}\" #{user}@#{@context_node.internal_interface_address}"
      else
        command = "ssh #{user}@#{@context_node.public_ip_address}"
      end     
      @context_node.execute_local(command)
    end

    def user
      @config[:user] ? @config[:user] : fallback_local_user
    end

    def fallback_local_user
      ::Bcome::System::Local.instance.local_user
    end

    ###### TODO - refactor out? BRANCH commands

    def node_host_or_ip
      has_proxy? ? @context_node.internal_interface_address : @context_node.public_ip_address
    end

    def ssh_keys
      ["~/.ssh/id_rsa"]  # TODO - this to come from our config file (within ssh settings), OR defaults to this
    end  

    def ssh_connect!
      net_ssh_params = { :keys => ssh_keys, :paranoid => false }
      net_ssh_params[:proxy] = proxy if has_proxy?

      begin
        @ssh_con = ::Net::SSH.start(node_host_or_ip, user, net_ssh_params)
      rescue Net::SSH::ConnectionTimeout
        raise "Could not initiate connection to #{self.namespace}"
      end
      return @ssh_con
    end

    def ssh_connection(bootstrap = false)
      return has_open_ssh_con? ? @ssh_con : ssh_connect!
    end

    def has_open_ssh_con?
      @ssh_con && !@ssh_con.closed?
    end


  end
end
