# frozen_string_literal: true

module Bcome::Terraform
  class Output
    require 'json'

    OUTPUT_COMMAND = 'terraform output -json'

    def initialize(namespace)
      @namespace = namespace
    end

    def output
      @output ||= get_output
    end

    private

    def terraform_installation_path
      @terraform_installation_path ||= "terraform/environments/#{@namespace.gsub(':', '_')}"
    end

    def get_output
      get_output_result = do_get_output

      # Until this feature is officially featured, failure to get terraform data will fail silently
      # One thing not decided upon yet is how to indicate that we wish to load terraform data or not.
      if get_output_result.failed?
        if get_output_result.stderr =~ /HTTP response code 401/
          raise "Received authorisation error retrieving metadata from Terraform outputs for namespace #{@namespace}. Command was '#{get_output_command}'. Are you authorised to access the TFstate?"
        end
        return {}
      end

      JSON.parse(get_output_result.stdout)
    end

    def get_output_command
      "cd #{terraform_installation_path} ; #{OUTPUT_COMMAND}"
    end

    def do_get_output
      ::Bcome::Command::Local.run(get_output_command)
    end
  end
end
