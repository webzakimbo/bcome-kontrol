# frozen_string_literal: true

module Bcome::Orchestration
  class InteractiveTerraform < Bcome::Orchestration::Base

    ## Prototype interactive terraform shell embedded within bcome.

    # * Provides access to the metadata framework, so that data may be shared between Orchestrative processes and Terraform
    # * Transparent authorization, by passing in cloud authorisation details from the bcome session
    # * Passes in SSH credentials directly, which can be used to bootstrap machines.

    QUIT = '\\q'
    COMMAND_PROMPT = "enter command or '#{QUIT}' to quit: " + 'terraform'.informational + "\s"

    def execute
      show_intro_text
      wait_for_command_input
    end

    def show_intro_text
      puts "\n"
      puts "INTERACTIVE TERRAFORM\n".underline
      puts "Namespace:\s" + @node.namespace.to_s.informational
      puts "Configuration Path:\s" + "#{path_to_env_config}/*".informational
      puts "\nConfigured metadata:\s" + terraform_metadata.inspect.informational

      puts "\nAny commands you enter here will be passed directly to Terraform in your configuration path scope."
    end

    # PROCESSING INTERACTIVE COMMANDS
    #
    def process_command(raw_command)

      if raw_command =~ /destroy/
        are_you_sure_message = "Are you SURE you want to 'destroy'? Make sure you know what will be destroyed before you continue. (y/n):".warning
        response = wait_for_input(are_you_sure_message)
        while(!["y", "n"].include?(response)) do
          response = wait_for_input(are_you_sure_message)          
        end
        return if response == "n"
      end

      full_command = command(raw_command)
      @node.execute_local(full_command)
      wait_for_command_input
    end

    # HANDLING USER INPUT
    #
    def wait_for_command_input
      raw_command = wait_for_input
      process_command(raw_command) unless raw_command == QUIT
    end

    def wait_for_input(message = COMMAND_PROMPT)
      ::Readline.readline("\n#{message}", true).squeeze('').to_s
    end

    # COMMAND PROCESSING
    def terraform_metadata
      @terraform_metadata ||= @node.metadata.fetch('terraform', @node.metadata.fetch(:terraform, {}))
    end

    # Get the terraform variables for this stack, and merge in with our networking & ssh credentials
    def form_var_string
      terraform_vars = terraform_metadata

      terraform_vars.each do |key, value|
        # Join arrays into a string (note we cannot handle nested arrays yet)
        terraform_vars[key] = value.join(',') if value.is_a?(Array)
      end

      cleaned_data = terraform_vars.reject do |_k, v|
        v.is_a?(Hash)
      end # we can't yet handle nested terraform metadata on the command line so no hashes

      all_vars = cleaned_data

      if @node.network_driver.has_network_credentials?
        network_credentials = @node.network_driver.network_credentials
        all_vars = cleaned_data.merge(network_credentials)
      end

      all_vars[:ssh_user] = @node.ssh_driver.user
      all_vars[:ssh_key_path] = @node.ssh_driver.ssh_keys.first

      all_vars.collect { |key, value| "-var #{key}=\"#{value}\"" }.join("\s")
    end

    def var_string
      @var_string ||= form_var_string
    end

    def backend_config_parameter_string
      ## Backend configs are loaded before Terraform Core which means that we cannot use variables directly in our backend config.
      ## This is a pain as we'll have authorised with GCP via the console, and so all sesssion have an access token readily available.
      ## This patch passes the access token directly to terraform as a parameter.

      ## GCP only for now. Support for AWS may come later as needed/requested.
      return "" unless @node.network_driver.is_a?(::Bcome::Driver::Gcp)
      return "\s-backend-config \"access_token=#{@node.network_driver.network_credentials[:access_token]}\"\s"
    end

    # Retrieve the path to the terraform configurations for this stack
    def path_to_env_config
      @path_to_env_config ||= "terraform/environments/#{@node.namespace.gsub(':', '_')}"
    end

    # Formulate a terraform command
    def command(raw_command)
      #if raw_command == "init"
      #  "cd #{path_to_env_config} ; terraform #{raw_command} #{backend_config_parameter_string}"
      #else
        "cd #{path_to_env_config} ; terraform #{raw_command} #{var_string}"
      #end
    end
  end
end
