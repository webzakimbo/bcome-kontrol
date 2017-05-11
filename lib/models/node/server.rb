module Bcome::Node
  class Server < Bcome::Node::Base
    class << self
      def new_from_fog_instance(fog_instance, parent)
        identifier = fog_instance.tags['Name']

        if parent.override_server_identifier?
          identifier =~ /#{parent.override_identifier}/
          identifier = Regexp.last_match(1) if Regexp.last_match(1)
        end

        params = {
          identifier: identifier,
          internal_interface_address: fog_instance.private_ip_address,
          public_ip_address: fog_instance.public_ip_address,
          role: fog_instance.tags['function'],
          description: "EC2 server - #{identifier}",
          type: 'server',
          ec2_server: fog_instance
        }

        new(parent: parent,
            view_data: params)
      end
    end

    def ls
      puts "\n" + visual_hierarchy.orange + "\n"
      puts pretty_description

      if ::Bcome::System::Local.instance.in_console_session?
        puts "\s\s\n\tType '?' to see your options\n\n".green
      else
        puts "\n\n"
      end
    end

    def machines
      [self]
    end
 
    def ssh
      ssh_driver.do_ssh
    end 

    def ping
      ping_result = ssh_driver.ping
      result = {
        namespace => {
          "connection" => ping_result ? "success" : "failed",
          "ssh_config" => ssh_driver.pretty_config_details
        }
      }

      colour = ping_result ? :green : :red

      ap result, options = {
        :color => {
           hash:  colour,
           symbol: colour,
           string: colour,
           keyword: colour,
           variable: colour,
           array: colour

        }
      }
    end

    def list_attributes
      {
        "identifier": :identifier,
        "internal ip": :internal_interface_address,
        "public ip": :public_ip_address,
      }
    end

    def do_run(raw_commands)
      raw_commands = raw_commands.is_a?(String) ? [raw_commands] : raw_commands
      commands = raw_commands.collect{|raw_command| ::Bcome::Ssh::Command.new({ :node => self, :raw => raw_command }) }
      command_exec = ::Bcome::Ssh::CommandExec.new(commands)
      command_exec.execute!
      return commands
    end

  end
end
