# frozen_string_literal: true

module ::Bcome::Ssh
  class ScriptExec
    class << self
      def execute(server, path_to_script)
        executor = new(server, path_to_script)
        executor.execute
      end
    end

    def initialize(server, path_to_script)
      @server = server
      @path_to_script = path_to_script
      @ssh_driver = server.ssh_driver
      @output_string = ''
    end

    def execute
      command = execute_command
      pretty_print(command)
      command
    end

    def execute_command
      raise Bcome::Exception::OrchestrationScriptDoesNotExist, @path_to_script unless File.exist?(@path_to_script)

      execute_script_command = "#{@ssh_driver.ssh_command} \"bash -s\" < #{@path_to_script}"
      command = ::Bcome::Command::Local.run(execute_script_command)
      command
    end

    def pretty_print(command)
      output_append("\n(#{@server.namespace})$".terminal_prompt + "> ./#{@path_to_script} - \s#{command.pretty_result}\n")
      output_append(command.stdout) # append stderr
      output_append "\nSTDERR: #{command.stderr}" if command.failed?
      puts "\n\n#{@output_string}\n\n"
    end

    def output_append(output_string)
      @output_string += "#{@output_string}#{output_string}"
    end
  end
end
