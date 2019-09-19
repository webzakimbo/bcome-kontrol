module ::Bcome::Ssh
  module DriverConnection

    DEFAULT_TIMEOUT_IN_SECONDS = 1

    attr_reader :connection

  def terminal
Net::SSH.start(node_host_or_ip, user, net_ssh_params) do |session|
 session.open_channel do |channel|
    channel.request_pty
    channel.send_channel_request "shell" do |ch, success|
      if success
        ch.send_data "env\n"
        ch.send_data "whoami\n"
        ch.on_data do |c, data|
          puts data
        end
      end
      channel.send_data "exit\n"

      channel.on_close do
        puts "shell closed"
      end
    end
  end
  end
end


   def terminal1
     puts "Connecting:"

     begin
      $stdin.raw!;

       Net::SSH.start(node_host_or_ip, user, net_ssh_params) do |session|
         puts "Opening session"
         session.open_channel do |channel|
           puts "Opening channel"
           channel.on_data do |_, data|
             $stdout.write(data)
           end
   
           channel.on_extended_data do |_, data|
             $stdout.write(data)
           end
 
            channel.request_pty do
             channel.send_channel_request "shell"
           end
 
            channel.connection.loop do
              $stdin.raw do |io|
                input = io.readpartial(1024)
                channel.send_data(input) unless input.empty?
              end
              channel.active?
            end

            session.listen_to(STDIN) { |stdin|
              input = stdin.readpartial(1024)
              channel.send_data(input) unless input.empty?
            }

          end.wait
        end
      ensure
        $stdin.echo = false;
      end
    end



    ## CONNECTION --

    def ssh_connect!
      @connection = nil
      begin
        @connection = ::Net::SSH.start(node_host_or_ip, user, net_ssh_params)
      rescue Net::SSH::Proxy::ConnectError, Net::SSH::ConnectionTimeout, Errno::EPIPE => e
        raise Bcome::Exception::CouldNotInitiateSshConnection, @context_node.namespace + "\s-\s#{e.message}"
      end
      @connection
    end

    def do_ssh_connect!
      connection_attempts = 0
      while connection_attempts < ::Bcome::Ssh::Connector::MAX_CONNECTION_ATTEMPTS
        begin
          connection = ssh_connect!
          return connection
        rescue Bcome::Exception::CouldNotInitiateSshConnection => e
          puts "Could not connect to #{@context_node.namespace}. Retrying".warning
          connection_attempts += 1
          raise e if connection_attempts == ::Bcome::Ssh::Connector::MAX_CONNECTION_ATTEMPTS
        end
      end
    end
 
    def close_ssh_connection
      return unless @connection

      @connection.close unless @connection.closed?
      @connection = nil
    end

    def ssh_connection(ping = false)
      if ping
        # We do not cache ping results
        do_ssh_connect!
      else
        has_open_ssh_con? ? @connection : do_ssh_connect!
      end
    end

    def has_open_ssh_con?
      !@connection.nil? && !@connection.closed?
    end

    def node_host_or_ip
      has_proxy? ? @context_node.internal_ip_address : @context_node.public_ip_address
    end

    def net_ssh_params
      raise Bcome::Exception::InvalidSshConfig, "Missing ssh keys for #{@context_node.namespace}" unless ssh_keys

      params = { keys: ssh_keys, paranoid: false }
      params[:proxy] = proxy if has_proxy?
      params[:timeout] = timeout_in_seconds
      params[:verbose] = :fatal # All but silent

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
