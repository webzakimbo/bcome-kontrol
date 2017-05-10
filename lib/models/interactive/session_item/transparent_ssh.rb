module Bcome::Interactive::SessionItem
  class TransparentSsh < ::Bcome::Interactive::SessionItem::Base

    END_SESSION_KEY = "\\q"
    HELP_KEY = "\\?"   
    LIST_KEY = "\\l"
    
    DANGER_CMD = "rm\s+-r|rm\s+-f|rm\s+-fr|rm\s+-rf|rm"

    def do
      show_menu
      puts ""
      open_ssh_connections!
      puts ""
      list_machines
      action 
    end

    def action
      input = get_input
      return if exit?(input)
      if show_menu?(input)
        show_menu
      elsif list_machines?(input)
        list_machines
      elsif command_may_be_unwise?(input)
        handle_the_unwise(input)   
      else
        execute_on_machines(input)
      end
      action
    end

    def show_menu
      system("clear") ; print start_message
    end

    def handle_the_unwise(input)
      if prompt_for_confirmation("Command may be dangerous to run on all machines. Are you sure you want to proceed? [Y|N] > ".danger)
        execute_on_machines(input)
      end
    end

    def command_may_be_unwise?(input)
      input =~ /#{DANGER_CMD}/
    end

    def prompt_for_confirmation(message)
      answer = get_input(message)
      unless ["Y", "N"].include?(answer)
        prompt_for_confirmation(message)
      end 
      return answer == "Y" ? true : false 
    end

    def start_message
      warning = "\nCommands entered here will be executed on EVERY machine in your selection.".danger
      second_warning = "\n\nUse with CAUTION.".danger
      info = "\n\n\\l list machines\n\\q to quit\n\\? this message".informational                                                             
      return "#{warning}#{second_warning}#{info}\n"
    end

    def terminal_prompt
      "#{bcome_identifier}>\s" + "interactive\s>\s".command   # high voltage
    end

    def valid_response(response)
      a = response.gsub("\s", "").downcase
      valid_responses.include?(response)
    end

    def exit?(input)
      input == END_SESSION_KEY
    end

    def show_menu?(input)
      input == HELP_KEY
    end
 
    def list_machines?(input)
      input == LIST_KEY 
    end

    def open_ssh_connections!
      ProgressBar.instance.reset!
      machines.pmap {|machine|
        ProgressBar.instance.indicate_and_increment!("init ssh: ","~~~", "connections")
        machine.ssh_connect!
      }
      ProgressBar.instance.reset!
    end

    def list_machines
      puts "\n"
      machines.each do |machine|
        env = machine.environment
        platform = env.platform
        puts "#{platform.identifier.cyan}:#{env.identifier.orange}:#{machine.identifier.yellow}"
      end
    end
 
    def get_input(message = terminal_prompt)
      return ::Readline.readline("\n#{message}", true).squeeze(" " ).to_s
    end

    def execute_on_machines(user_input)
      machines.pmap {|machine|
        machine.run(user_input)
      }
    end

    def machines
      @machines ||= has_selected_machines? ? selected_machines.collect(&:node) : flat_list_of_machines
    end

    def flat_list_of_machines
      resources.collect{|resource| resource.node.machines }.flatten
    end

    def resources
      @irb_session.resources  
    end

    def has_selected_machines?
      selected_machines.is_a?(Array) && selected_machines.any?
    end

    def selected_machines
      @selections ||= @irb_session.instance_variable_get(:@objects)
    end

  end
end
