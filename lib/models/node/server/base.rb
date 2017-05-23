module Bcome::Node::Server
  class Base < Bcome::Node::Base

    def type
      "server"
    end

    def machines
      [self]
    end

    def server?
      true
    end

    def requires_description?
      false
    end

    def requires_type?
      false
    end

    def ssh
      ssh_driver.do_ssh
    end

    def ls
      puts "\n" + visual_hierarchy.bc_orange + "\n"
      puts pretty_description

      if ::Bcome::System::Local.instance.in_console_session?
        puts "\s\s\n\tType '?' to see your options\n\n".bc_green
      else
        puts "\n\n"
      end
    end

    def ping
      ping_result = ssh_driver.ping
      print_ping_result(ping_result)
    end

    def print_ping_result(ping_result = { success: true })
      result = {
        namespace => {
          "connection" => ping_result[:success] ? "success" : "failed",
          "ssh_config" => ssh_driver.pretty_config_details
        }
      }

      unless ping_result[:success]
        result[namespace]["error"] = ping_result[:error].message
      end

      colour = ping_result[:success] ? :green : :red

      ap result, {
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
      attribs = {
        "identifier": :identifier,
        "internal ip": :internal_interface_address,
        "public ip": :public_ip_address,
      }

      attribs.merge!("description": :description ) if has_description?
      attribs
    end

    def do_run(raw_commands)
      raw_commands = raw_commands.is_a?(String) ? [raw_commands] : raw_commands
      commands = raw_commands.collect{|raw_command| ::Bcome::Ssh::Command.new({ :node => self, :raw => raw_command }) }
      command_exec = ::Bcome::Ssh::CommandExec.new(commands)
      command_exec.execute!
      return commands
    end

    def has_description?
      !@description.nil?
    end

  end  
end
