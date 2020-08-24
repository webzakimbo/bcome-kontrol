# frozen_string_literal: true

module ::Bcome::Ssh
  module DriverConnection
    DEFAULT_TIMEOUT_IN_SECONDS = 1

    attr_reader :connection

    ## CONNECTION --

    def ssh_connect!
      @connection = nil
      begin
        raise ::Bcome::Exception::InvalidProxyConfig, "missing target ip address for #{@context_node.identifier}. Perhaps you meant to configure a proxy?" unless node_host_or_ip

        @connection = ::Net::SSH.start(node_host_or_ip, user, net_ssh_params)
      rescue Net::SSH::AuthenticationFailed, Net::SSH::Proxy::ConnectError, Net::SSH::ConnectionTimeout => e
        raise Bcome::Exception::CouldNotInitiateSshConnection, @context_node.namespace + "\s-\s#{e.message}"
      end
      @connection
    end

    def close_ssh_connection
      return unless @connection

      begin
        @connection.close unless @connection.closed?
        @connection = nil
      rescue Net::SCP::Error
        @connection = nil
      end
    end

    def ssh_connection(ping = false)
      if ping
        # We do not cache ping results
        ssh_connect!
      else
        has_open_ssh_con? ? @connection : ssh_connect!
      end
    end

    def has_open_ssh_con?
      !@connection.nil? && !@connection.closed?
    end

    def node_host_or_ip
      return @context_node.internal_ip_address if @context_node.local_network?

      has_proxy? ? @context_node.internal_ip_address : @context_node.public_ip_address
    end

    def net_ssh_params
      params = { paranoid: false }
      params[:proxy] = proxy if has_proxy?
      params[:timeout] = timeout_in_seconds
      params[:verbose] = :fatal # All but silent

      params
    end

    def timeout_in_seconds
      @config[:timeout_in_seconds] ||= DEFAULT_TIMEOUT_IN_SECONDS
    end

    ## PROXYING --

    def proxy
      connection_wrangler.proxy
    end
  end
end
