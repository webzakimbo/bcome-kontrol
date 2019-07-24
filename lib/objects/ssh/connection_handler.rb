# frozen_string_literal: true

module Bcome::Ssh
  class ConnectionHandler
    MAX_CONNECTION_ATTEMPTS = 3

    class << self
      def connect(node, config = {})
        handler = new(node, config)
        handler.connect
      end
    end

    def initialize(node, config = {})
      @node = node
      @config = config
      @servers_to_connect = machines.dup
      @connection_exceptions = {}
      reset_progress if show_progress?
    end

    def machines
      skip_for_hidden = true # Skip servers withen hidden namespaces
      @node.server? ? [@node] : @node.machines(skip_for_hidden)
    end

    def show_progress?
      @config[:show_progress] ? true : false
    end

    def ping?
      @config[:is_ping] ? true : false
    end

    def reset_progress
      ::Bcome::ProgressBar.instance.reset!
    end

    def ping
      connect
    end

    def connect
      connection_attempt = 0
      ::Bcome::ProgressBar.instance.indicate(progress_bar_config, true) if show_progress?

      # So here we have a bit of a hack: If you're connecting to a network via a bastion host, it may not be able to handle over a certain amount of consecutive/parallelized ssh connection attempts
      # from bcome, so, we'll sweep up failures and re-try to connect up to MAX_CONNECTION_ATTEMPTS.  Once connected, we're generally good - and any subsequent connection failures
      # within a specific session will be handled ad-hoc and re-connection is automatic.
      while @servers_to_connect.any? && connection_attempt <= MAX_CONNECTION_ATTEMPTS
        puts "Retrying failed connections\n".warning if connection_attempt > 1
        do_connect
        connection_attempt += 1
      end

      if show_progress?
        ::Bcome::ProgressBar.instance.indicate(progress_bar_config, false)
        reset_progress
      end

      if ping?
        # If any machines remain, then we couldn't connect to them
        @servers_to_connect.each do |server|
          ping_result = {
            success: false,
            error: last_connection_exception_for(server)
          }
          puts server.print_ping_result(ping_result)
        end
      end

      if @servers_to_connect.any?
        puts "Failed to connect to #{@servers_to_connect.size} nodes".error
      else
        puts 'All nodes reachable   '.success
      end
    end

    def last_connection_exception_for(server)
      @connection_exceptions[server]
    end

    def do_connect
      @servers_to_connect.pmap do |server|
        begin
          server.open_ssh_connection unless server.has_ssh_connection?
          Bcome::ProgressBar.instance.indicate_and_increment!(progress_bar_config, true) if show_progress?
          @servers_to_connect -= [server]
          puts server.print_ping_result if ping?
        rescue Exception => e
          @connection_exceptions[server] = e
        end
      end
    end

    def progress_bar_config
      {
        prefix: "\sOpening SSH connections\s",
        indice: '...',
        indice_descriptor: "of #{machines.size}"
      }
    end
  end
end
