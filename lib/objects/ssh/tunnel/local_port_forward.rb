# frozen_string_literal: true

module Bcome::Ssh::Tunnel
  class LocalPortForward
    def initialize(tunnel_command)
      @tunnel_command = tunnel_command
      @process_pid = nil
    end

    def open!
      @process_pid = spawn(@tunnel_command)
    end

    def close!
      puts "Closing tunnel:\s".informational + "#{@tunnel_command}".terminal_prompt
      ::Process.kill('HUP', @process_pid)
    end
  end
end
