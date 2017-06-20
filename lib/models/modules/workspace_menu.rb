module Bcome::WorkspaceMenu

  def menu
    print "\n\n"
    enabled_menu_items.each_with_index do |menu_item, index|
      puts tab_spacing + "#{menu_item}".bc_cyan + item_spacing(menu_item) + "#{menu_items[menu_item][:description]}".bc_yellow
      if usage = menu_items[menu_item][:usage]
        puts tab_spacing + ("\s" * menu_item_spacing_length) + "usage: ".bc_magenta + usage
      end
      puts "\n"
    end
    return
  end  

  def item_spacing(item)
    "\s" * (menu_item_spacing_length - item.length)
  end

  def menu_item_spacing_length
    14
  end  

  def tab_spacing
    "\s" * 3
  end 

  def menu_items
    {
      ls: {
        description: "list all available resources"
      },
      lsa: {
        description: "list all active resources"
      },
      workon: {
        description: "work on specific resources only, inactivating all others from this selection",
        usage: "workon identifier1, identifier2 ..."
      },
      disable: {
        description: "remove a resource from this selection",
        usage: "disable identifier1, identifier2 ..."
      },
      enable: {
        description: "re-enable a resource within this selection",
        usage: "enable identifier1, identifier2 ..."
      },
      enable!: {
        description: "enable all resources within this selection"
      },
      disable!: {
        description: "disable all resources within this selection"
      },
      run: {
        description: "execute a command to be run over ssh against all active resources",
        usage: "run 'command'"
      },
      interactive: {
        description: "enter an interactive command session for all active resources"
      },
      tree: {
        description: "print a recursive tree view for all resources and their sub-resources"
      },
      ping: {
        description: "recursively ping all resources to test connectivity"
      },
      put: {
        description: "upload a file",
        usage: "put 'local/path','remote/path'"
      },
      get: {
        description: "download a file",
        usage: "get 'remote/path', 'local/path'"
      },
      cd: {
        description: "enter the namespace for a resource from this selection",
        usage: "cd identifier"
      },
      ssh: {
        description: "initiate an ssh connection to this server"
      },
      save: {
        description: "Save the current tree state"
      },
      reload!: {
        description: "Restock our inventories from remote"
      }
    }
  end

end
