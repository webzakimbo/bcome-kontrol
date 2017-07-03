require 'open3'

module Bcome::Command
  class Local
    def self.run(raw_command)
      command = new(raw_command)
      command.syscall
      command
    end

    attr_reader :stdout, :stderr, :exit_code

    def initialize(command)
      @command = command
    end

    def syscall
      @stdout, @stderr, @exit_code = Open3.capture3(@command)
    rescue Exception => e
      @exit_code = 1
      @stderr = e.message
    end

    def success?
      @exit_code == 0
    end

    def failed?
      !success?
    end
  end
end
