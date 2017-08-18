module Bcome::Node::RegistryManagement

  def user_command_wrapper
    @user_command_wrapper ||= ::Bcome::Registry::Loader.instance.command_group_for_node(self)
  end

  # TODO - check for conflicts somehow: should not be able to add registry commands that override system commands
  def registry
    command_group = user_command_wrapper
    if command_group.has_commands?
      command_group.pretty_print
    else  
      puts "\nThere are no registered user commands for this namespace\n".warning
    end
  end

end
