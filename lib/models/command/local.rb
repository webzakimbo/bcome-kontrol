require 'open3'

module Bcome::Command
  class Local

    def self.run(command)
      command = new(command)
      command.syscall
      command 
    end

    attr_reader :output, :exit_code

    def initialize(command)
      @command = command
    end

    def syscall
      begin
        Open3.popen2e("#{@command};") do |stdin, stdout_err, wait_thr|
          @output = stdout_err.read.split("\n")
          @exit_code = wait_thr.value.exitstatus
        end
      rescue Exception => e
        @exit_code = 1
        @output = [e.message]
      end
    end

    def success?
      @exit_code == 0
    end

  end
end
