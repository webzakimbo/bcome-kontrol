module Bcome::Ssh
  class Driver

    attr_reader :config

    PROXY_CONNECT_PREFIX="ssh -o StrictHostKeyChecking=no -W %h:%p"
    PROXY_SSH_PREFIX="ssh -o UserKnownHostsFile=/dev/null -o \"ProxyCommand ssh -W %h:%p"
    DEFAULT_TIMEOUT_IN_MILLISECONDS = 4000

    def initialize(config, context_node)
      @config = config
      @context_node = context_node
      @proxy_data = @config[:proxy] ? ::Bcome::Ssh::ProxyData.new(@config[:proxy], @context_node) : nil
    end

    def pretty_config_details
      config = {
        user: user,
        ssh_keys: @config[:ssh_keys],
        timeout: timeout_in_milliseconds
      }
      if has_proxy?
        config.merge!({
          host_or_ip: @context_node.internal_interface_address,
          proxy: {
            bastion_host:  @proxy_data.host,
            bastion_host_user: bastion_host_user
          }
        })
      else
        config.merge!({
          host_or_ip: @context_node.public_ip_address 
        })
      end
      config
    end

    def timeout_in_milliseconds
      @config[:timeout_milliseconds] ||= Bcome::Ssh::Driver::DEFAULT_TIMEOUT_IN_MILLISECONDS
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


    def node_host_or_ip
      has_proxy? ? @context_node.internal_interface_address : @context_node.public_ip_address
    end

    def ssh_connect!(verbose = false)
      ssh_keys = @config[:ssh_keys]
      raise ::Bcome::Exception::InvalidSshConfig.new("Missing ssh keys for #{@context_node.namespace}") unless ssh_keys
      net_ssh_params = { :keys => ssh_keys, :paranoid => false }
      net_ssh_params[:proxy] = proxy if has_proxy?
      net_ssh_params[:timeout] = timeout_in_milliseconds
      net_ssh_params[:verbose] = :debug if verbose
      begin
        @ssh_con = ::Net::SSH.start(node_host_or_ip, user, net_ssh_params)
      rescue Net::SSH::ConnectionTimeout
        raise ::Bcome::Exception::CouldNotInitiateSshConnection.new("#{@context_node.namespace}.  Fix the issue and use bcome #{@context_node.namespace}:ping command to verify it's worked")
      end
      return @ssh_con
    end

    def ping
      success = false
      begin
        ssh_connect!
        success = true
      rescue
      end
      return success
    end

    def ssh_connection(bootstrap = false)
      return has_open_ssh_con? ? @ssh_con : ssh_connect!
    end

    def has_open_ssh_con?
      @ssh_con && !@ssh_con.closed?
    end

  end
end
