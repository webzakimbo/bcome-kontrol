module ::Bcome::Ssh
  module DriverConnection

    DEFAULT_TIMEOUT_IN_SECONDS = 5

    ## CONNECTION --

    def ssh_connect!(_verbose = false)
      @connection = nil
      begin
        @connection = ::Net::SSH.start(node_host_or_ip, user, net_ssh_params)
      rescue Net::SSH::Proxy::ConnectError, Net::SSH::ConnectionTimeout, Errno::EPIPE => e
        raise Bcome::Exception::CouldNotInitiateSshConnection, @context_node.namespace + "\s-\s#{e.message}"
      end
      @connection
    end

    def close_ssh_connection
      return unless @connection

      @connection.close unless @connection.closed?
      @connection = nil
    end

    def ssh_connection
      has_open_ssh_con? ? @connection : ssh_connect!
    end

    def has_open_ssh_con?
      !@connection.nil? && !@connection.closed?
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

    def timeout_in_seconds
      @config[:timeout_in_seconds] ||= DEFAULT_TIMEOUT_IN_SECONDS
    end

    ## SSH KEYS

    def ssh_keys
      @config[:ssh_keys]
    end

    ## PROXYING --

    def proxy
      return connection_wrangler.proxy
    end

  end
end
