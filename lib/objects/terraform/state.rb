module Bcome::Terraform
  class State
    require 'json'

    TSTATE_FILENAME = "terraform.tfstate".freeze

    def initialize(namespace)
      @namespace = namespace
    end

    def terraform_installation_path
      # Look for a terraform config installation in the path belonging to this node
      @terraform_installation_path ||= "terraform/environments/#{@namespace.gsub(":","_")}"
    end

    def config_path
      "#{terraform_installation_path}/#{TSTATE_FILENAME}"
    end

    def config_exists?
      File.exist?(config_path)
    end

    def config
      raise "No terraform tstate for this environment" unless config_exists?
      JSON.parse(File.read(config_path))
    end

    def resources
      return {} unless config_exists?
      return config["modules"][0]["resources"]
    end
  end
end
