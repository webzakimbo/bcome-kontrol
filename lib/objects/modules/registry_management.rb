module Bcome::Node::RegistryManagement

  def user_command_wrapper
    @user_command_wrapper ||= do_load_user_command_wrapper
  end

  def do_load_user_command_wrapper
    ::Bcome::Registry::Loader.instance.command_group_for_node(self)
  end  

  def registry
    command_group = user_command_wrapper
    if command_group.has_commands?
      command_group.pretty_print
    else  
      puts "\nThere are no registered user commands for this namespace\n".warning
    end
  end

end
