module ::Bcome::Ssh
  module DriverUser

    def user
      # If we're in bootstrapping mode and have a bootstrap user set, return it
      return @bootstrap_settings.user if bootstrap? && @bootstrap_settings.user

      # If we have a user explictly set in the config, then return it
      return @config[:user] if @config[:user]

      # If the local user has explicitly overriden their user, return that
      return overriden_local_user if overriden_local_user

      # Else fall back to whichever local user is using bcome
      fallback_local_user
    end

    def overriden_local_user
      @overriden_local_user ||= get_overriden_local_user
    end

    def get_overriden_local_user
      ::Bcome::Node::Factory.instance.local_data[:ssh_user]
    end

    def fallback_local_user
      @fallback_local_user ||= ::Bcome::System::Local.instance.local_user
    end

   def fallback_bastion_host_user
      # This defines the default bastion host ssh username to utilise if bastion_host_user has not been set
      # in a given proxy hop config.

      # If bootstrapping mode is defined along with a bootstrapping bastion host use, then use that
      return bootstrap_settings.bastion_host_user if has_bootstrap_settings? && bootstrap_settings.bastion_host_user
       
      # Otherwise we'll fall back to the local defined user
      return user
    end

  end
end
