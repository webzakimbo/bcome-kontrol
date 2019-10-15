# frozen_string_literal: true

module ::Bcome::Ssh
  module DriverUser
    def user
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
      user
    end
  end
end
