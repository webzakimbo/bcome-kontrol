# frozen_string_literal: true

module Bcome::Registry::Command
  class Shortcut < Base
    # In which the bcome context is a shortcut to a more complex command

    def execute(node, _arguments) ## We'll add in arguments later
      begin
        if run_as_pseudo_tty?
          node.pseudo_tty command
        else
          puts "\n(#{node.namespace})$".terminal_prompt + ">\s#{command}"
          ::Bcome::Orchestrator.instance.tail_all_command_output!(node)
          node.run command
          ::Bcome::Orchestrator.instance.reset!
        end
      rescue Interrupt
        ::Bcome::Orchestrator.instance.reset!
        puts "\nExiting gracefully from interrupt\n".warning
      end
      nil
    end

    def command
      @data[:shortcut_command]
    end

    def run_as_pseudo_tty?
      @data[:run_as_pseudo_tty]
    end
  end
end
