# frozen_string_literal: true

module Bcome::Interactive::SessionItem
  class TransparentSsh < ::Bcome::Interactive::SessionItem::Base
    END_SESSION_KEY = '\\q'
    HELP_KEY = '\\?'
    LIST_KEY = '\\l'

    DANGER_CMD = "rm\s+-r|rm\s+-f|rm\s+-fr|rm\s+-rf|rm"

    def machines
      skip_for_hidden = true
      node.server? ? [node] : node.machines(skip_for_hidden)
    end

    def do
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
        #close_ssh_connections
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
      warning = "\n\sCommands entered here will be executed on " + 'EVERY'.underline + ' machine in your selection.'
      second_warning = "\n\n\s" + 'Use with CAUTION.'.warning
      info = "\n\n\s\\l list machines\n\s\\q to quit\n\s\\? this message".informational
      puts "#{warning}#{second_warning}#{info}\n"
    end

    def handle_the_unwise(input)
      execute_on_machines(input) if prompt_for_confirmation('Command may be dangerous to run on all machines. Are you sure you want to proceed? [Y|N] > '.error)
    end

    def command_may_be_unwise?(input)
      input =~ /#{DANGER_CMD}/
    end

    def prompt_for_confirmation(message)
      answer = get_input(message)
      prompt_for_confirmation(message) unless %w[Y N].include?(answer)
      answer == 'Y'
    end

    def start_message; end

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
      ::Bcome::Ssh::Connector.connect(node, show_progress: true)
      system('clear')
    end

    def close_ssh_connections
      node.close_ssh_connections
    end

    def indicate_failed_nodes(unconnected_nodes)
      unconnected_nodes.each do |node|
        puts "\s\s - #{node.namespace}".bc_cyan
      end
    end

    def list_machines
      puts "\n"
      machines.each do |machine|
        puts "\s- #{machine.namespace}"
      end
    end

    def execute_on_machines(user_input)
      machines.pmap do |machine|
       begin
         machine.run(user_input)
       rescue IOError => e
         puts "Reopening connection to\s".informational +  machine.identifier
         machine.reopen_ssh_connection
         machine.run(user_input)
        end
      end
    end
  end
end
