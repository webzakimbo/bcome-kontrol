# frozen_string_literal: true

module ::Bcome::Ssh
  class ScriptExec
    SCRIPTS_PATH = 'bcome/scripts'

    class << self
      def execute(server, script_name)
        executor = new(server, script_name)
        executor.execute
      end
    end

    def initialize(server, script_name)
      @server = server
      @script_name = script_name
      @ssh_driver = server.ssh_driver
    end

    def execute
      command = execute_command
      pretty_print(command)
      command
    end

    def execute_command
      local_path_to_script = "#{SCRIPTS_PATH}/#{@script_name}.sh"
      raise Bcome::Exception::OrchestrationScriptDoesNotExist, local_path_to_script unless File.exist?(local_path_to_script)

      execute_script_command = "#{@ssh_driver.ssh_command} \"bash -s\" < #{local_path_to_script}"
      command = ::Bcome::Command::Local.run(execute_script_command)
      command
    end

    def pretty_print(command)
      output_append("\n(#{@server.namespace})$".terminal_prompt + "> ./#{SCRIPTS_PATH}/#{@script_name}.sh - \s#{command.pretty_result}\n")
      output_append(command.stdout) # append stderr
      output_append "\nSTDERR: #{command.stderr}" if command.failed?
      puts "\n\n#{@output_string}\n\n"
    end

    def output_append(output_string)
      @output_string = "#{@output_string}#{output_string}"
    end
  end
end
