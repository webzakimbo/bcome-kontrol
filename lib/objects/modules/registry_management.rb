# frozen_string_literal: true

module Bcome
  module Node
    module RegistryManagement

      def command_group
        @command_group ||= command_list.group_for_node(self)
      end

      def command_list
        ::Bcome::Registry::CommandList.instance
      end  

      def registry
        if command_group&.has_commands?
          command_group.pretty_print
        else
          puts "\nYou have no registry commands configured for this namespace.\n".warning
        end
      end

      def pretty_list_for_node
        return "" unless list_for_node.any?
        return list_for_node.join(", ")
      end

      def list_for_node
        command_list.group_for_node(self).all_commands.collect{|group_name, commands| commands}.flatten.collect{|cmd| cmd.console_command  }
      end

    end
  end
end
