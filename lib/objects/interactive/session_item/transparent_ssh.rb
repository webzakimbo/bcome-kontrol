module Bcome::Interactive::SessionItem
  class TransparentSsh < ::Bcome::Interactive::SessionItem::Base
    END_SESSION_KEY = '\\q'.freeze
    HELP_KEY = '\\?'.freeze
    LIST_KEY = '\\l'.freeze

    DANGER_CMD = "rm\s+-r|rm\s+-f|rm\s+-fr|rm\s+-rf|rm".freeze

    def resources
      node.server? ? [node] : node.resources
    end

    def do
      Bcome::ProgressBar.instance.reset!
      system('clear')
      puts ''
      open_ssh_connections
      show_menu
      puts ''
      list_machines
      action
    end

    def action
      input = get_input

      if exit?(input)
        close_ssh_connections
        return
      end

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
      print start_message
    end

    def handle_the_unwise(input)
      if prompt_for_confirmation('Command may be dangerous to run on all machines. Are you sure you want to proceed? [Y|N] > '.error)
        execute_on_machines(input)
      end
    end

    def command_may_be_unwise?(input)
      input =~ /#{DANGER_CMD}/
    end

    def prompt_for_confirmation(message)
      answer = get_input(message)
      prompt_for_confirmation(message) unless %w[Y N].include?(answer)
      answer == 'Y' ? true : false
    end

    def start_message
      warning = "\n\sCommands entered here will be executed on " + 'EVERY'.underline + ' machine in your selection.'
      second_warning = "\n\n\s" + 'Use with CAUTION.'.warning
      info = "\n\n\s\\l list machines\n\s\\q to quit\n\s\\? this message".informational
      "#{warning}#{second_warning}#{info}\n"
    end

    def terminal_prompt
      ">\s".bold.terminal_prompt
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

    def open_ssh_connections
      in_progress = true
      Bcome::ProgressBar.instance.indicate(progress_bar_config, in_progress)

      node.machines.pmap do |machine|
        machine.open_ssh_connection unless machine.has_ssh_connection?
        Bcome::ProgressBar.instance.indicate_and_increment!(progress_bar_config, in_progress)
      end

      in_progress = false
      Bcome::ProgressBar.instance.indicate(progress_bar_config, in_progress)
      Bcome::ProgressBar.instance.reset!
      system("clear")
    end

    def close_ssh_connections
      node.close_ssh_connections
    end

    def indicate_failed_nodes(unconnected_nodes)
     puts "Error: Could not initiate an ssh connection to the following nodes".error
     unconnected_nodes.each do |node|
       puts "\s\s - #{node.namespace}".bc_cyan
     end
    end

    def progress_bar_config
      {
        prefix: "\sOpening SSH connections\s",
        indice: '...',
        indice_descriptor: "of #{node.machines.size}"
      }
    end

    def list_machines
      puts "\n"
      node.machines.each do |machine|
        puts "\s- #{machine.namespace}"
      end
    end

    def execute_on_machines(user_input)
      resources.pmap do |machine|
        machine.run(user_input)
      end
    end
  end
end
