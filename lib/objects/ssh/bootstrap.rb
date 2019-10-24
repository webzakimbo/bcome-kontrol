# frozen_string_literal: true

module Bcome::Ssh
  class Bootstrap
    def initialize(config)
      @config = config
    end

    def ssh_key_path
      key_path = `eval directory=#{@config[:ssh_key_path]}; echo $directory`
      key_path =~ /(.+)\n/
      Regexp.last_match(1)
    end

    def user
      @config[:user]
    end

    def bastion_host_user
      @config[:bastion_host_user]
    end
  end
end
