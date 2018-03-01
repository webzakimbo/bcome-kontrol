require 'open3'

module Bcome::Command
  class Local
    def self.run(raw_command, _success_exit_codes = [0])
      command = new(raw_command)
      command.syscall
      command
    end

    attr_reader :stdout, :stderr, :process_status

    def initialize(command, success_exit_codes = [0])
      @command = command
      @success_exit_codes = success_exit_codes
    end

    def syscall
      @stdout, @stderr, @process_status = Open3.capture3(@command)
    rescue Exception => e
      @stderr = e.message
    end

    def exit_code
      @process_status ? @process_status.exitstatus : 1
    end

    def is_success?
      @success_exit_codes.include?(exit_code)
    end

    def failed?
      !is_success?
    end

    def pretty_result
      is_success? ? "success / exit code: #{exit_code}".success : "failure / exit code: #{exit_code}".error
    end
  end
end
