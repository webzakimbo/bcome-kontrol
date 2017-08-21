module Bcome::Registry::Command
  class Group

    attr_reader :all_commands

    def initialize(node)
      @all_commands = {}
      @node = node
    end

    def <<(command)
      @all_commands[command.group] ? (@all_commands[command.group] << command) : (@all_commands[command.group] = [command])
    end

    def has_commands?
      @all_commands.keys.any?
    end
 
    def pretty_print
      puts "\nRegistered commands".title + "\sfor #{@node.class} #{@node.namespace}".resource_value + "\n\n"
      @all_commands.sort.each do |group_name, commands|
        puts "\s\s\s\s" + group_name.title + "\n\n"
        commands.each do |command|
          command.pretty_print
        end
        print "\n"
      end 
      return nil 
    end  
 
  end
end
