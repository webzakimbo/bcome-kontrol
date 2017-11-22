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

    def item_spacing(item)
      "\s" * (menu_item_spacing_length - item.length)
    end

    def menu_item_spacing_length
      16
    end

    def tab_spacing
      "\s" * 3
    end

    def pretty_print
      puts "\nRegistry commands".title + "\sfor #{@node.class} #{@node.keyed_namespace}".resource_value + "\n\n"
      all_commands.sort.each do |group_name, commands|   
        puts tab_spacing + group_name.title + "\n\n"
        commands.each do |command|
          command_key = command.console_command
          description = command.description
          defaults = command.defaults

          puts tab_spacing + command_key.resource_key + item_spacing(command_key) + description.resource_value 

          if ::Bcome::System::Local.instance.in_console_session?
            usage_string = "#{command_key}"
          else
            usage_string = "bcome #{ @node.keyed_namespace.empty? ? "" : "#{@node.keyed_namespace}:"    }#{command_key}"
          end 
 
          puts tab_spacing + ("\s" * menu_item_spacing_length) + 'usage: '.instructional + usage_string + defaults.inspect + "\n\n"

        end
        puts "\n"
      end
      nil
    end

  end
end
