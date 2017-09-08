module Bcome::Ssh
  class Driver
    attr_reader :config

    DEFAULT_TIMEOUT_IN_SECONDS = 5
    PROXY_CONNECT_PREFIX = 'ssh -o StrictHostKeyChecking=no -W %h:%p'.freeze
    PROXY_SSH_PREFIX = 'ssh -o UserKnownHostsFile=/dev/null -o "ProxyCommand ssh -W %h:%p'.freeze

    SCRIPTS_PATH = 'bcome/scripts'.freeze

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
      @context_node.execute_local(ssh_command)
    end

    def do_execute_script(script_name)
      local_path_to_script = "#{SCRIPTS_PATH}/#{script_name}.sh"
      raise Bcome::Exception::OrchestrationScriptDoesNotExist, local_path_to_script unless File.exist?(local_path_to_script)
      execute_script_command = "#{ssh_command} \"bash -s\" < #{local_path_to_script}"
      command = ::Bcome::Command::Local.run(execute_script_command)
      command
    end

    def ssh_command
      if has_proxy?
        "#{PROXY_SSH_PREFIX} #{bastion_host_user}@#{@proxy_data.host}\" #{user}@#{@context_node.internal_ip_address}"
      else
        "ssh #{user}@#{@context_node.public_ip_address}"
      end
    end

    def user
      @config[:user] ? @config[:user] : fallback_local_user
    end

    def fallback_local_user
      @fallback_local_user ||= ::Bcome::System::Local.instance.local_user
    end

    def node_host_or_ip
      has_proxy? ? @context_node.internal_ip_address : @context_node.public_ip_address
    end

    def net_ssh_params(verbose = false)
      ssh_keys = @config[:ssh_keys]
      raise Bcome::Exception::InvalidSshConfig, "Missing ssh keys for #{@context_node.namespace}" unless ssh_keys

      params = { keys: @config[:ssh_keys], paranoid: false }
      params[:proxy] = proxy if has_proxy?
      params[:timeout] = timeout_in_seconds
      params[:verbose] = :debug if verbose
      return params
    end

    def ssh_connect!(verbose = false)
      begin
        Timeout::timeout(timeout_in_seconds) do      
          @connection = ::Net::SSH.start(node_host_or_ip, user, net_ssh_params)
        end
      rescue Timeout::Error => e
        raise Bcome::Exception::CouldNotInitiateSshConnection, @context_node.namespace + "\s-\s#{e.message}"
      rescue Errno::EPIPE => e
        raise Bcome::Exception::CouldNotInitiateSshConnection, @context_node.namespace + "\s-\s#{e.message}"
      end
      return @connection
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
