module Bcome::Registry::Command
  class Group
    def initialize(node)
      @all_commands = {}
      @node = node
    end

    attr_reader :all_commands

    def <<(command)
      all_commands[command.group] ? (all_commands[command.group] << command) : (all_commands[command.group] = [command])
    end

    def has_commands?
      all_commands.keys.any?
    end

    def console_method_name_exists?(proposed_name)
      user_registered_console_command_names.include?(proposed_name)
    end

    def user_registered_console_command_names
      user_registered_console_commands.collect(&:console_command)
    end

    def user_registered_console_commands
      all_commands.collect { |_group, commands| commands }.flatten
    end

    def command_for_console_command_name(command_name)
      user_registered_console_commands.select { |command| command.console_command.to_sym == command_name }.first
    end

    def pretty_print
      puts "\nRegistered commands".title + "\sfor #{@node.class} #{@node.keyed_namespace}".resource_value + "\n\n"
      all_commands.sort.each do |group_name, commands|
        puts "\s\s\s\s" + group_name.title + "\n\n"
        commands.each(&:pretty_print)
        print "\n"
      end
      nil
    end
  end
end
