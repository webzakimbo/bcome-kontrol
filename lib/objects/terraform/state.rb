# frozen_string_literal: true

module Bcome::Terraform
  class State
    require 'json'

    TSTATE_FILENAME = 'terraform.tfstate'

    def initialize(namespace)
      @namespace = namespace
    end

    def terraform_installation_path
      # Look for a terraform config installation in the path belonging to this node
      @terraform_installation_path ||= "terraform/environments/#{@namespace.gsub(':', '_')}"
    end

    def config_path
      "#{terraform_installation_path}/#{TSTATE_FILENAME}"
    end

    def config_exists?
      File.exist?(config_path)
    end

    def config
      return {} unless config_exists?

      JSON.parse(File.read(config_path))
    end

    def modules
      return {} unless config_exists?

      config['modules']
    end

    def resources
      return {} unless config_exists?
      config['resources'][0]
    end
  end
end
