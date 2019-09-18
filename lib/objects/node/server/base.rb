# frozen_string_literal: true

module Bcome::Node::Server
  class Base < Bcome::Node::Base
    attr_reader :origin_object_id

    def initialize(*params)
      super
      # Set the object_id - sub inventories dup servers into new collections. This allows us to spot duplicates when interacting with collections
      @origin_object_id = object_id
    end

    def host
      raise "Should be overidden"
    end 

    # override a server namespace's parameters. This enables features such as specific SSH parameters for a specific server, e.g. my use case was a
    # single debian box within an ubuntu network, where I needed to access the machine with the 'admin' rather 'ubuntu' username.
    def set_view_attributes
      super
      overridden_attributes = ::Bcome::Node::Factory.instance.machines_data_for_namespace(namespace.to_sym)
      overridden_attributes.each do |override_key, override_value|
        instance_variable_name = "@#{override_key}"
        instance_variable_set(instance_variable_name, override_value)
      end
    end

    def dup_with_new_parent(new_parent)
      new_node = clone
      new_node.update_parent(new_parent)
      new_node
    end

    def update_parent(new_parent)
      @parent = new_parent
    end

    def tags
      data_print_from_hash(cloud_tags.data, 'Tags')
    end

    def cloud_tags
      @generated_tags ||= do_generate_cloud_tags
    end

    def has_tagged_value?(key, values)
      matchers = { key: key, values: values }
      cloud_tags.has_key_and_value?(matchers)
    end

    def update_identifier(new_identifier)
      @identifier = new_identifier
    end

    def do_generate_cloud_tags
      raise 'Should be overidden'
    end

    def type
      'server'
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

    def enabled_menu_items
      (super + %i[get ssh tags pseudo_tty tunnel]) - %i[enable disable enable! disable!]
    end

    def menu_items
      base_items = super.dup
      base_items[:tags] = {
        description: 'print out remote EC2 tags'
      }
      base_items[:ssh] = {
        description: 'initiate an ssh connection to this server'
      }
      base_items[:get] = {
        description: 'Download a file or directory',
        console_only: false,
        usage: 'get "/remote/path", "/local/path"',
        terminal_usage: 'get "/remote/path" "/local/path"'
      }
      base_items[:pseudo_tty] = {
        description: 'Invoke a pseudo-tty session',
        console_only: false,
        usage: 'pseudo_tty "your command"',
        terminal_usage: 'pseudo_tty "your command"'
      }
      base_items[:tunnel] = {
        description: 'Create a Tunnel over SSH',
        console_only: false,
        usage: 'tunnel(local_port, destination_port)',
        terminal_usage: 'tunnel local_port destination_port'
      }

      base_items
    end

    def local_port_forward(start_port, end_port)
      ssh_driver.local_port_forward(start_port, end_port)
    end
    alias :tunnel :local_port_forward

    def reopen_ssh_connection
      puts "Lost connection to #{identifier}. Reopening".warning
      close_ssh_connection
      open_ssh_connection
    end

    def open_ssh_connection(ping = false)
      ssh_driver.ssh_connection(ping)
    end

    def close_ssh_connection
      ssh_driver.close_ssh_connection
    end

    def has_ssh_connection?
      ssh_driver.has_open_ssh_con?
    end

    def has_no_ssh_connection?
      !has_ssh_connection?
    end

    def ssh
      ssh_driver.do_ssh
    end

    def pseudo_tty(command)
      as_pseudo_tty = true
      ssh_cmd = ssh_driver.ssh_command(as_pseudo_tty)
      tty_command = "#{ssh_cmd} '#{command}'"
      execute_local(tty_command)
    end

    def execute_script(script_name)
      command_result = ::Bcome::Ssh::ScriptExec.execute(self, script_name)
      command_result
    end

    def rsync(local_path, remote_path)
      ssh_driver.rsync(local_path, remote_path)
    end

    def put(local_path, remote_path, *params)
      ssh_driver.put(local_path, remote_path)
    end

    def put_str(string, remote_path, *params)
      ssh_driver.put_str(string, remote_path)
    end

    def get(remote_path, local_path)
      ssh_driver.get(remote_path, local_path)
    end

    def ls
      puts "\n" + visual_hierarchy.hierarchy + "\n"
      puts pretty_description
    end
    alias lsa ls

    def ping
      ping_result = ssh_driver.ping
      print_ping_result(ping_result)
    end

    def print_ping_result(ping_result = { success: true })
      result = {
        namespace => {
          'connection' => ping_result[:success] ? 'success' : 'failed',
          'ssh_config' => ssh_driver.pretty_ssh_config
       }
      }

      result[namespace]['error'] = ping_result[:error].message unless ping_result[:success]

      colour = ping_result[:success] ? :green : :red

      ap(result, { indent: -2, color:  { hash: colour, symbol: colour, string: colour, keyword: colour, variable: colour, array: "cyan" }} )
    end

    def list_attributes
      attribs = {
        "identifier": :identifier,
        "internal ip": :internal_ip_address,
        "public ip": :public_ip_address,
        "host": :host
      }

      #attribs.merge!("description": :description) if has_description?
      attribs
    end

    def cache_data
      d = { identifier: identifier }
      d[:internal_ip_address] = internal_ip_address if internal_ip_address
      d[:public_ip_address] = public_ip_address if public_ip_address
      d[:description] = description if description
      d[:cloud_tags] = cloud_tags
      d
    end

    def do_run(raw_commands)
      raw_commands = raw_commands.is_a?(String) ? [raw_commands] : raw_commands
      commands = raw_commands.collect { |raw_command| ::Bcome::Ssh::Command.new(node: self, raw: raw_command) }
      command_exec = ::Bcome::Ssh::CommandExec.new(commands)
      command_exec.execute!
      commands.each(&:unset_node)
      commands
    end

    def run(*raw_commands)
      begin
        raise ::Bcome::Exception::MethodInvocationRequiresParameter, "Please specify commands when invoking 'run'" if raw_commands.empty?
        return do_run(raw_commands)
     rescue IOError, Errno::EBADF
       reopen_ssh_connection
       return do_run(raw_commands)
      rescue Exception => e
        if e.message == "Unexpected spurious read wakeup"
          reopen_ssh_connection
          return do_run(raw_commands)
        else
          raise e
        end  
     end
    end

    def has_description?
      !@description.nil?
    end

    def static_server?
      false
    end

    def dynamic_server?
      !static_server?
    end
  end
end
