module Bcome::Node::RegistryManagement
  def user_command_wrapper
    @user_command_wrapper ||= ::Bcome::Registry::CommandList.instance.group_for_node(self)
  end

  def registry
    command_group = user_command_wrapper
    if command_group && command_group.has_commands?
      command_group.pretty_print
    else
      puts "\nYou have no registry commands configured for this namespace.\n".warning
    end
  end
end
