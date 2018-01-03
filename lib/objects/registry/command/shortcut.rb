module Bcome::Registry::Command
  class Shortcut < Base
    # In which the bcome context is a shortcut to a more complex command

    def execute(node, arguments)  ## We'll add in arguments later
      node.run @data[:shortcut_command]
    rescue Interrupt
      puts "\nExiting gracefully from interrupt\n".warning
    end

  end
end
