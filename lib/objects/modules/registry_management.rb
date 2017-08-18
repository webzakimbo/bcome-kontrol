module Bcome::Node::RegistryManagement

  def user_commands
    @user_commands ||= ::Bcome::Registry::Loader.instance.commands_for_namespace(namespace)
  end

end
