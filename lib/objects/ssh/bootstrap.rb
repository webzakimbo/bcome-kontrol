module Bcome::Ssh
  class Bootstrap
    def initialize(config)
      @config = config
    end

    def ssh_key_path
      @config[:ssh_key_path]
    end

    def user
      @config[:user]
    end

    def bastion_host_user
      @config[:bastion_host_user]
    end
  end
end
