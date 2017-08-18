module Bcome::Registry::Command
  class Group

    def initialize
      @all_commands = {}
    end

    def <<(command)
      @all_commands[command.group] ? (@all_commands[command.group] << command) : (@all_commands[command.group] = [command])
    end
  
  end
end
