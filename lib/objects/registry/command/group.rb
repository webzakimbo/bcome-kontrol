# frozen_string_literal: true

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
      raise ::Bcome::Exception::InvalidRegistryCommandNameLength, "command '#{item}' exceeds length limit of #{menu_item_spacing_length}" if item.length > menu_item_spacing_length

      "\s" * (menu_item_spacing_length - item.length)
    end

    def menu_item_spacing_length
      16
    end

    def tab_spacing
      "\s" * 3
    end

    def in_console_session?
      ::Bcome::System::Local.instance.in_console_session?
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

          usage_string = in_console_session? ? command_key.to_s : "bcome #{@node.keyed_namespace.empty? ? '' : "#{@node.keyed_namespace}:"}#{command_key}"
          puts tab_spacing + ("\s" * menu_item_spacing_length) + 'usage: '.instructional + usage_string

          if defaults.keys.any?
            defaults_usage = in_console_session? ? "\s#{defaults.collect { |key, _value| "\"#{key}=your-value\"" }.join(",\s")}" : "\s" + defaults.collect { |key, _value| "#{key}=your-value" }.join("\s")
            puts tab_spacing + ("\s" * menu_item_spacing_length) + "defaults:\s".instructional + defaults.collect { |k, v| "#{k}=#{v}" }.join(', ')
            puts tab_spacing + ("\s" * menu_item_spacing_length) + "override:\s".instructional + usage_string + defaults_usage
          end
          puts "\n"
        end
        puts "\n"
      end
      nil
    end
  end
end
