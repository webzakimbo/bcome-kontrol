module Bcome::Ssh::Tunnel
  class LocalPortForward
 
    def initialize(tunnel_command)
      @tunnel_command = tunnel_command
      @process_pid = nil
    end 

    def open!
      puts "Opening tunnel: #{@tunnel_command}".informational
      @process_pid = spawn(@tunnel_command)
    end

    def close!
      puts "Closing tunnel with process pid ##{@process_pid}: #{@tunnel_command}".informational
      ::Process.kill("HUP", @process_pid)
    end

  end
end
