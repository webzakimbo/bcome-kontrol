module ::Bcome::Ssh
  class CommandExec

    attr_reader :commands

    def initialize(commands)
      @commands = commands
    end

    def output_append(output_string)
      @output_string = "#{@output_string}#{output_string}"
    end

    def print_output
      print "#{@output_string}\n\n"
    end

    def execute!
      @commands.each { |command|
        node = command.node
        ssh = node.ssh_driver.ssh_connection
        ssh_exec!(ssh, command)
        output_append("\n(#{node.identifier})$".cyan + ">\s#{command.raw} (#{command.pretty_result})\n")
        output_append("#{command.output}")
      }
    end

    def ssh_exec!(ssh, command)
      ssh.open_channel do |channel|
        channel.exec(command.raw) do |ch, success|
          unless success
            abort "FAILED: couldn't execute command (ssh.channel.exec)"
          end
          channel.on_data do |ch,data|
            command.stdout += data
          end
          channel.on_extended_data do |ch,type,data|
            command.stderr += data
          end
          channel.on_request("exit-status") do |ch,data|
            command.exit_code = data.read_long
          end
          channel.on_request("exit-signal") do |ch, data|
            command.exit_signal = data.read_long
          end
        end
       end
      ssh.loop
    end

  end
end

