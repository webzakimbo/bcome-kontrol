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
      @commands.each do |command|
        node = command.node
        ssh = node.ssh_driver.ssh_connection
        ssh_exec!(ssh, command)
        output_append("\n(#{node.namespace})$".bc_cyan + ">\s#{command.raw} (#{command.pretty_result})\n")
        output_append(command.output.to_s)
        print_output
      end
    end

    def ssh_exec!(ssh, command)
      ssh.open_channel do |channel|
        channel.exec(command.raw) do |_cha, success|
          unless success
            abort "FAILED: couldn't execute command (ssh.channel.exec)"
          end

          channel.on_data do |_ch, data|
            command.stdout += data
          end

          channel.on_extended_data do |_ch, _type, data|
            command.stderr += data
          end

          channel.on_request('exit-status') do |_ch, data|
            command.exit_code = data.read_long
          end

          channel.on_request('exit-signal') do |_ch, data|
            command.exit_signal = data.read_long
          end
        end
      end
      ssh.loop
    end
  end
end
