module Bcome
  module Ssh
    class Connector 

      include ::LoadingBar::Handler

      MAX_CONNECTION_ATTEMPTS = 3

      class << self
        def connect(node, config = {})
          handler = new(node, config)
          handler.connect
        end
      end

      def initialize(node, config)
        @node = node
        @config = config
        set_servers
        @connected_machines = []
        @connection_exceptions = {}
      end

      def show_progress?
        @config[:show_progress] ? true : false
      end

      def ping?
        @config[:is_ping] ? true : false
      end

      def connect
        connection_attempt = 0

        # We may have difficulty connecting to many machines simultaneously, especially if, for examples, connections are being proxied via
        # a single jump host. Here we have a slight hack - we'll keep on attempting to connect up to MAX_CONNECTION_ATTEMPTS, moping up failures
        # along the way. Once connected any subsequent failures will be handled gracefully, with re-connection automatic.
        while @servers_to_connect.any? && connection_attempt <= MAX_CONNECTION_ATTEMPTS
          title = connection_attempt > 1 ? "Retrying failed connections" : "Connecting"
          start_indicator(@servers_to_connect.size, title, "done") if show_progress?
          open_connections
          connection_attempt += 1
          signal_stop if show_progress?
        end

        report_connection_outcome
      end
 
      def report_connection_outcome
        print "\n"

        if ping?
          @connected_machines.pmap do |machine|
            puts machine.print_ping_result
          end
  
          # If any machines remain, then we couldn't connect to them
          @servers_to_connect.each do |machine|
            ping_result = {
              success: false,
              error: @connection_exceptions[machine]
            }
            puts machine.print_ping_result(ping_result)
          end
        end

        puts "Failed to connect to #{@servers_to_connect.size} node#{@servers_to_connect.size > 1 ? "s" : "" }".error if @servers_to_connect.any?
      end

      def open_connections
        @servers_to_connect.pmap do |machine|
          begin
            machine.open_ssh_connection
            if machine.has_ssh_connection?
              @servers_to_connect -= [machine]
              @connected_machines << machine
              signal_success if show_progress?
            else
              signal_failure if show_progress?
            end
          rescue Bcome::Exception::CouldNotInitiateSshConnection => e
            @connection_exceptions[machine] = e
          end
        end
      end

      private

      def set_servers
        @servers_to_connect = machines.dup
      end
      
      def machines
        skip_for_hidden = true # Skip servers with hidden namespaces
        @node.server? ? [@node] : @node.machines(skip_for_hidden)
      end

    end
  end
end
