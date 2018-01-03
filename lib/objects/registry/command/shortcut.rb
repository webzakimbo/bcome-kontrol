module Bcome::Registry::Command
  class Shortcut < Base
    # In which the bcome context is a shortcut to a more complex command

    def execute(node, arguments)  ## We'll add in arguments later
      if run_as_pseudo_tty?
        node.pseudo_tty command
      else
        node.run command
      end
    rescue Interrupt
      puts "\nExiting gracefully from interrupt\n".warning
    end

    def command
      @data[:shortcut_command]
    end
 
    def run_as_pseudo_tty?
      @data[:run_as_pseudo_tty]
    end
 
  end
end
