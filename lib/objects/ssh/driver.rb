module Bcome::Ssh
  class Driver
    attr_reader :config, :bootstrap_settings

    DEFAULT_TIMEOUT_IN_SECONDS = 5
    PROXY_CONNECT_PREFIX = '-o StrictHostKeyChecking=no -W %h:%p'.freeze
    PROXY_SSH_PREFIX = '-o UserKnownHostsFile=/dev/null -o "ProxyCommand ssh -W %h:%p'.freeze

    def initialize(config, context_node)
      @config = config
      @context_node = context_node
      @proxy_data = @config[:proxy] ? ::Bcome::Ssh::ProxyData.new(@config[:proxy], @context_node) : nil
      @bootstrap_settings = @config[:bootstrap_settings] ? ::Bcome::Ssh::Bootstrap.new(@config[:bootstrap_settings]) : nil
    end

    def bootstrap?
      @context_node.bootstrap? && has_bootstrap_settings?
    end

    def has_bootstrap_settings?
      !@bootstrap_settings.nil?
    end

    def pretty_config_details
      config = {
        user: user,
        ssh_keys: ssh_keys,
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
      connection_string = bootstrap? ? bootstrap_proxy_connection_string : proxy_connection_string
      ::Net::SSH::Proxy::Command.new(connection_string)
    end

    def has_proxy?
      return false if proxy_config_value && proxy_config_value == -1
      !@config[:proxy].nil?
    end

    def proxy_config_value
      @config[:proxy]
    end

    def proxy_connection_string
      "ssh #{PROXY_CONNECT_PREFIX} #{bastion_host_user}@#{@proxy_data.host}"
    end

    def bootstrap_proxy_connection_string
      "ssh -i #{@bootstrap_settings.ssh_key_path} -o StrictHostKeyChecking=no -W %h:%p #{@bootstrap_settings.bastion_host_user}@#{@proxy_data.host}"
    end

    def do_ssh
      cmd = ssh_command
      @context_node.execute_local(cmd)
    end

    def bastion_host_user
      bootstrap? && @bootstrap_settings.bastion_host_user ? @bootstrap_settings.bastion_host_user : @proxy_data.bastion_host_user ? @proxy_data.bastion_host_user : user
    end

    def ssh_command
      return bootstrap_ssh_command if bootstrap? && @bootstrap_settings.ssh_key_path

      if has_proxy?
        "ssh #{PROXY_SSH_PREFIX} #{bastion_host_user}@#{@proxy_data.host}\" #{node_level_ssh_key_connection_string}#{user}@#{@context_node.internal_ip_address}"
      else
        "ssh #{node_level_ssh_key_connection_string}#{user}@#{@context_node.public_ip_address}"
      end
    end

    def node_level_ssh_key_connection_string
      key_specified_at_node_level? ? "-i #{node_level_ssh_key}\s" : ""
    end

    def key_specified_at_node_level?
      !node_level_ssh_key.nil?
    end  

    def node_level_ssh_key
      return (@config[:ssh_keys]) ? @config[:ssh_keys].first : nil
    end

    def local_port_forward(start_port, end_port)
      if has_proxy?
        
        if bootstrap?
          tunnel_command = "ssh -N -L #{start_port}:#{@context_node.internal_ip_address}:#{end_port} -i #{@bootstrap_settings.ssh_key_path} #{bastion_host_user}@#{@proxy_data.host}"
        else
          tunnel_command = "ssh -N -L #{start_port}:#{@context_node.internal_ip_address}:#{end_port} #{bastion_host_user}@#{@proxy_data.host}"
        end
      else
        if bootstrap?
          tunnel_command = "ssh -i #{@bootstrap_settings.ssh_key_path} -N -L #{start_port}:#{@context_node.public_ip_address}:#{end_port}"
        else
          tunnel_command = "ssh -N -L #{start_port}:#{@context_node.public_ip_address}:#{end_port}"
        end
      end

      tunnel = ::Bcome::Ssh::Tunnel::LocalPortForward.new(tunnel_command)
      tunnel.open!
      return tunnel
    end

    def bootstrap_ssh_command
      if has_proxy?
        "ssh -i #{@bootstrap_settings.ssh_key_path} -t #{bastion_host_user}@#{@proxy_data.host} ssh -t #{user}@#{@context_node.internal_ip_address}"
      else
        "ssh -i #{@bootstrap_settings.ssh_key_path} #{user}@#{@context_node.public_ip_address}"
      end
    end

    def user
      # If we're in bootstrapping mode and have a bootstrap user set, return it
      return @bootstrap_settings.user if (bootstrap? && @bootstrap_settings.user)

      # If we have a user explcitly set in the config, then return it
      return @config[:user] if @config[:user]

      # If the local user has explicitly overriden their user, return that
      return overriden_local_user if overriden_local_user

      # Else fall back to whichever local user is using bcome
      fallback_local_user
    end

    def overriden_local_user
      @overriden_local_user ||= get_overriden_local_user
    end

    def get_overriden_local_user
      ::Bcome::Node::Factory.instance.local_data[:ssh_user]       
    end

    def fallback_local_user
      @fallback_local_user ||= ::Bcome::System::Local.instance.local_user
    end

    def node_host_or_ip
      has_proxy? ? @context_node.internal_ip_address : @context_node.public_ip_address
    end

    def net_ssh_params(verbose = false)
      raise Bcome::Exception::InvalidSshConfig, "Missing ssh keys for #{@context_node.namespace}" unless ssh_keys
      params = { keys: ssh_keys, paranoid: false }
      params[:proxy] = proxy if has_proxy?
      params[:timeout] = timeout_in_seconds
      params[:verbose] = :debug if verbose
      params
    end

    def ssh_keys
      if bootstrap?
        [@bootstrap_settings.ssh_key_path]
      else
        @config[:ssh_keys]
      end
    end

    def rsync(local_path, remote_path)
      raise Bcome::Exception::MissingParamsForRsync, "'rsync' requires a local_path and a remote_path" if local_path.to_s.empty? || remote_path.to_s.empty?
      command = rsync_command(local_path, remote_path)
      @context_node.execute_local(command)
    end

    def rsync_command(local_path, remote_path)
      return bootstrap_rsync_command(local_path, remote_path) if bootstrap? && @bootstrap_settings.ssh_key_path
      if has_proxy?
        "rsync -av -e \"ssh -A #{bastion_host_user}@#{@proxy_data.host} ssh -o StrictHostKeyChecking=no\" #{local_path} #{user}@#{@context_node.internal_ip_address}:#{remote_path}"
      else
        "rsync -av #{local_path} #{user}@#{@context_node.public_ip_address}:#{remote_path}"
      end
    end

    def bootstrap_rsync_command(local_path, remote_path)
      if has_proxy?
        "rsync -av -e \"ssh -i #{@bootstrap_settings.ssh_key_path} -A #{bastion_host_user}@#{@proxy_data.host} ssh -o StrictHostKeyChecking=no\" #{local_path} #{user}@#{@context_node.internal_ip_address}:#{remote_path}"
      else
        "rsync -i #{@bootstrap_settings.ssh_key_path} -av #{local_path} #{user}@#{@context_node.public_ip_address}:#{remote_path}"
      end
    end

    def ssh_connect!(_verbose = false)
      @connection = nil
      begin
        @connection = ::Net::SSH.start(node_host_or_ip, user, net_ssh_params)
      rescue Net::SSH::Proxy::ConnectError, Net::SSH::ConnectionTimeout, Errno::EPIPE => e
        raise Bcome::Exception::CouldNotInitiateSshConnection, @context_node.namespace + "\s-\s#{e.message}"
      end
      @connection
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
      raise Bcome::Exception::MissingParamsForScp, "'put' requires a local_path and a remote_path" if local_path.to_s.empty? || remote_path.to_s.empty?
      puts "\n(#{@context_node.namespace})\s".namespace + "Uploading #{local_path} to #{remote_path}\n".informational

      begin
        scp.upload!(local_path, remote_path, recursive: true) do |_ch, name, sent, total|
          puts "#{name}: #{sent}/#{total}".progress
        end
      rescue Exception => e # scp just throws generic exceptions :-/
        puts e.message.error
      end
      nil
    end

    def get(remote_path, local_path)
      raise Bcome::Exception::MissingParamsForScp, "'get' requires a local_path and a remote_path" if local_path.to_s.empty? || remote_path.to_s.empty?
      puts "\n(#{@context_node.namespace})\s".namespace + "Downloading #{remote_path} to #{local_path}\n".informational

      begin
        scp.download!(remote_path, local_path, recursive: true) do |_ch, name, sent, total|
          puts "#{name}: #{sent}/#{total}".progress
        end
      rescue Exception => e # scp just throws generic exceptions :-/
        puts e.message.error
      end
    end

    def close_ssh_connection
      return unless @connection
      @connection.close unless @connection.closed?
      @connection = nil
    end

    def ssh_connection(_bootstrap = false)
      has_open_ssh_con? ? @connection : ssh_connect!
    end

    def has_open_ssh_con?
      !@connection.nil? && !@connection.closed?
    end
  end
end
