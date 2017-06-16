module Bcome::Ssh
  class Driver
    attr_reader :config

    DEFAULT_TIMEOUT_IN_SECONDS = 5
    PROXY_CONNECT_PREFIX = 'ssh -o StrictHostKeyChecking=no -W %h:%p'.freeze
    PROXY_SSH_PREFIX = 'ssh -o UserKnownHostsFile=/dev/null -o "ProxyCommand ssh -W %h:%p'.freeze

    def initialize(config, context_node)
      @config = config
      @context_node = context_node
      @proxy_data = @config[:proxy] ? ::Bcome::Ssh::ProxyData.new(@config[:proxy], @context_node) : nil
    end

    def pretty_config_details
      config = {
        user: user,
        ssh_keys: @config[:ssh_keys],
        timeout: timeout_in_seconds
      }
      if has_proxy?
        config[:host_or_ip] = @context_node.internal_ip_address
        config[:proxy] = {
          bastion_host:  @proxy_data.host,
          bastion_host_user: bastion_host_user
        }
      else
        config[:host_or_ip] = @context_node.public_ip_address
      end
      config
    end

    def timeout_in_seconds
      @config[:timeout_in_seconds] ||= Bcome::Ssh::Driver::DEFAULT_TIMEOUT_IN_SECONDS
    end

    def proxy
      return nil unless has_proxy?
      ::Net::SSH::Proxy::Command.new(proxy_connection_string)
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
        command = "#{PROXY_SSH_PREFIX} #{bastion_host_user}@#{@proxy_data.host}\" #{user}@#{@context_node.internal_ip_address}"
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
      has_proxy? ? @context_node.internal_ip_address : @context_node.public_ip_address
    end

    def ssh_connect!(verbose = false)
      ssh_keys = @config[:ssh_keys]
      raise Bcome::Exception::InvalidSshConfig, "Missing ssh keys for #{@context_node.namespace}" unless ssh_keys
      net_ssh_params = { keys: ssh_keys, paranoid: false }
      net_ssh_params[:proxy] = proxy if has_proxy?
      net_ssh_params[:timeout] = timeout_in_seconds
      net_ssh_params[:verbose] = :debug if verbose
      begin
        # We handle timeouts in code rather than on the connection itself: rationale - bcome doesn't care at which hop in a connection a timeout occurs, just that it has.
        Timeout.timeout timeout_in_seconds do
          @ssh_con = ::Net::SSH.start(node_host_or_ip, user, net_ssh_params)
        end
      rescue Timeout::Error => e
        raise Bcome::Exception::CouldNotInitiateSshConnection, @context_node.namespace + "\s-\s#{e.message}"
      rescue Errno::EPIPE => e
        raise Bcome::Exception::CouldNotInitiateSshConnection, @context_node.namespace + "\s-\s#{e.message}"
      end 
      @ssh_con
    end

    def ping
      ssh_connect!
      return { success: true }
    rescue Exception => e
      return { success: false, error: e }
    end

    def scp
      ssh_connection.scp
    end

    def put(local_path, remote_path)
      raise Bcome::Exception::MissingParamsForScp.new("'put' requires a local_path and a remote_path") if local_path.to_s.empty? || remote_path.to_s.empty?
      puts "\n(#{@context_node.namespace})\s".bc_cyan + "Uploading #{local_path} to #{remote_path}\n".bc_magenta
  
      begin
        scp.upload!(local_path, remote_path) do |ch, name, sent, total|
          puts "#{name}: #{sent}/#{total}".bc_yellow
        end
      rescue Exception => e  # scp just throws generic exceptions :-/
        puts e.message.bc_red
      end
      return
    end

    def get(remote_path, local_path)
      raise Bcome::Exception::MissingParamsForScp.new("'get' requires a local_path and a remote_path") if local_path.to_s.empty? || remote_path.to_s.empty?
      puts "\n(#{@context_node.namespace})\s".bc_cyan + "Downloading #{remote_path} to #{local_path}\n".bc_magenta

      begin
      scp.download!(remote_path, local_path) do |ch, name, sent, total|
        puts "#{name}: #{sent}/#{total}".bc_yellow
      end
      rescue Exception => e # scp just throws generic exceptions :-/
        puts e.message.bc_red
      end  
    end

    def ssh_connection(_bootstrap = false)
      has_open_ssh_con? ? @ssh_con : ssh_connect!
    end

    def has_open_ssh_con?
      @ssh_con && !@ssh_con.closed?
    end
  end
end
