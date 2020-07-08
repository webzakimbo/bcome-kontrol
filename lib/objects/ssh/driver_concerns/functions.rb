# frozen_string_literal: true

module ::Bcome::Ssh
  module DriverFunctions
    def do_ssh
      cmd = ssh_command
      @context_node.execute_local(cmd)
    end

    def rsync(local_path, remote_path)
      raise Bcome::Exception::MissingParamsForRsync, "'rsync' requires a local_path and a remote_path" if local_path.to_s.empty? || remote_path.to_s.empty?

      command = rsync_command(local_path, remote_path)
      @context_node.execute_local(command)
    end

    def local_port_forward(start_port, end_port)
      tunnel_command = local_port_forward_command(start_port, end_port)

      if ::Bcome::Workspace.instance.console_set?
        puts "\sOpening ssh tunnel:\s".informational + tunnel_command.to_s.terminal_prompt
        tunnel = ::Bcome::Ssh::Tunnel::LocalPortForward.new(tunnel_command)
        ::Bcome::Ssh::TunnelKeeper.instance << tunnel
        tunnel.open!
        tunnel
      else
        puts "\n\nOpening ssh tunnel".informational + "\slocalhost:#{start_port} ~> #{@context_node.namespace}:#{end_port}"
        puts "\nTo use, navigate to another terminal window or application."
        puts "\nctrl+c to close."
        ::Bcome::Command::Local.run(tunnel_command)
      end
    end

    def ping
      ssh_connect!
      { success: true }
    rescue Exception => e
      { success: false, error: e }
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

    def put_str(string, remote_path, silence_progress = false)
      raise Bcome::Exception::MissingParamsForScp, "'put' requires a string and a remote_path" if string.nil? || remote_path.to_s.empty?

      puts "\n(#{@context_node.namespace})\s".namespace + "Uploading from string to #{remote_path}\n".informational unless silence_progress

      begin
        scp.upload!(StringIO.new(string), remote_path) do |_ch, name, sent, total|
          puts "#{name}: #{sent}/#{total}".progress unless silence_progress
        end
      rescue StandardError => e 
        raise ::Bcome::Exception::Generic, e.message
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
      rescue Exception => e
        puts e.message.error
      end
    end
  end
end
