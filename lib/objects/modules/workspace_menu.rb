# frozen_string_literal: true

module Bcome
  module WorkspaceMenu
    def menu
      print "\n\n"
      puts "COMMAND MENU".bc_cyan + "\sfor #{self.class} #{namespace}".resource_value

      grouped_menu_items = menu_items.group_by {|m| m[1][:group] }
      grouped_menu_items.each do |group_key, items| 
       
        # If we're not in a console session, we filter out console only methods 
        unless ::Bcome::System::Local.instance.in_console_session?
          items = items.reject{|item| item[1][:console_only] }
        end

        next if items.empty?
      
        s_heading = "/ #{menu_group_names[group_key]}"        
        print "\n\n" + tab_spacing + s_heading.upcase.bc_cyan 
        print item_spacing(s_heading) + "#{"\s" * 110}".bc_cyan.underline
        print "\n\n"
        print_menu_items(items)  
      end

      nil
    end

    def print_menu_items(items)
      items.each_with_index do |item, _index|
        key = item[0]
        config = item[1]

        next if !::Bcome::System::Local.instance.in_console_session? && config[:console_only]

        puts tab_spacing + key.to_s.resource_key + item_spacing(key) + (config[:description]).to_s.resource_value
        if config[:usage] || config[:terminal_usage]
          usage_string = ::Bcome::System::Local.instance.in_console_session? ? config[:usage] : "bcome #{keyed_namespace.empty? ? '' : "#{keyed_namespace}:"}#{config[:terminal_usage]}"
          puts tab_spacing + ("\s" * menu_item_spacing_length) + 'usage: '.instructional + usage_string
        end
        puts "\n"
      end
    end

    def mode
      ::Bcome::System::Local.instance.in_console_session? ? 'Console' : 'Terminal'
    end

    def item_spacing(item)
      "\s" * (menu_item_spacing_length - item.length)
    end

    def menu_item_spacing_length
      16
    end

    def tab_spacing
      "\s" * 3
    end
 
    def menu_group_names
      {
        :ssh =>"Ssh",
        :informational => "Informational",
        :selection => "Selections",
        :file => "File & Script",
        :navigation => "Navigational",
        :miscellany => "Miscellaneous",
        :command_list => "Command lists"
      }
    end


    def menu_items
      {
        ls: {
          description: 'list all available namespaces',
          console_only: false,
          group: :informational
        },
        lsa: {
          description: 'list all active namespaces',
          console_only: true,
          group: :informational
        },
        workon: {
          description: 'work on specific namespaces only, inactivating all others from this selection',
          usage: 'workon identifier1, identifier2 ...',
          console_only: true,
          group: :selection,
        },
        disable: {
          description: 'remove a namespace from this selection',
          usage: 'disable identifier1, identifier2 ...',
          console_only: true,
          group: :selection
        },
        enable: {
          description: 're-enable a namespace within this selection',
          usage: 'enable identifier1, identifier2 ...',
          console_only: true,
          group: :selection
        },
        enable!: {
          description: 'enable all namespaces within this selection',
          console_only: true,
          group: :selection
        },
        disable!: {
          description: 'disable all namespaces within this selection',
          console_only: true,
          group: :selection
        },
        run: {
          description: 'execute a command to be run over ssh against all active namespaces',
          usage: "run 'command1', 'command2', ...",
          console_only: false,
          terminal_usage: "run 'command1' 'command2' ...",
          group: :ssh
        },
        interactive: {
          description: 'enter an interactive command session for all active namespaces',
          console_only: false,
          group: :ssh
        },
        tree: {
          description: 'print a tree view for all namespaces and their sub-namespaces',
          console_only: false,
          group: :informational
        },
        ping: {
          description: 'ping all namespaces to test connectivity',
          console_only: false,
          group: :ssh
        },
        put: {
          description: 'upload a file or directory using scp',
          usage: "put 'local/path','remote/path'",
          console_only: false,
          terminal_usage: "put 'local/path' 'remote/path'",
          group: :file
        },
        put_str: {
          description: 'Write a file /to/remote/path from a string',
          usage: 'put_str "string" "remote/path"',
          console_only: false,
          terminal_usage: "put_str '<file contents>', 'remote/path'",
          group: :file
        },
        rsync: {
          description: 'upload a file or directory using rsync (faster)',
          usage: "rsync 'local/path','remote/path'",
          console_only: false,
          terminal_usage: "rsync 'local/path' 'remote/path'",
          group: :file
        },
        get: {
          description: 'download a file',
          usage: "get 'remote/path', 'local/path'",
          console_only: false,
          terminal_usage: "get 'remote/path' 'local/path",
          group: :file
        },
        cd: {
          description: 'enter a console session for a child namespace from this selection',
          usage: 'cd identifier',
          console_only: true,
          group: :navigation
        },
        exit!: {
          description: "Quit out of bcome",
          usage: "exit!",
          console_only: true,
          group: :navigation
        },
        back: {
          description: "Go up a namespace, or exit",
          usage: "back",
          console_only: true,
          group: :navigation
        },
        cache: {
          description: 'Cache the current tree state',
          console_only: false,
          group: :miscellany
        },
        meta: {
          description: 'Print out all metadata related to this node',
          group: :informational
        },
        registry: {
          description: 'List all user defined commands present in your registry, and available to this namespace',
          console_only: false,
          group: :command_list
        }, 
        menu: {
          description: 'List all available commands',
          console_only: false,
          group: :command_list
        },
        execute_script: {
          description: 'execute a bash script',
          console_only: false,
          usage: 'execute_script "script_name"',
          terminal_usage: 'execute_script script_name',
          group: :ssh
        }
      }
    end
  end
end
