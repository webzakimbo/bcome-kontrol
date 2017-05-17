require 'open3'

module Bcome::Command
  class Local
    def self.run(raw_command)
      command = new(raw_command)
      command.syscall
      command
    end

    attr_reader :output, :exit_code

    def initialize(raw_command)
      @raw_command = raw_command
    end

    def syscall
      Open3.popen2e("#{@raw_command};") do |_stdin, stdout_err, wait_thr|
        @output = stdout_err.read
        @exit_code = wait_thr.value.exitstatus
      end
    rescue Exception => e
      @exit_code = 1
      @output = e.message
    end

    def success?
      @exit_code == 0
    end

    def failed?
      !success?
    end

    def print_output
      puts "\n" + @output
    end
  end
end
