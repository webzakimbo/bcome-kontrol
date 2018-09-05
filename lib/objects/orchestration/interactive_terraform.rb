module Bcome::Orchestration
  class InteractiveTerraform < Bcome::Orchestration::Base 

    QUIT = "\\q"
    COMMAND_PROMPT = "enter command or '#{QUIT}' to quit: " + "terraform".informational + "\s"

    def execute
      show_intro_text
      wait_for_command_input
    end
 
    def show_intro_text
      puts "\n"
      puts "INTERACTIVE TERRAFORM\n".underline
      puts "Namespace:\s" + "#{@node.namespace}".informational
      puts "Configuration Path:\s" + "#{path_to_env_config}/*".informational
      puts "\nConfigured metadata:\s" 
      puts terraform_metadata.inspect.informational

      puts "\nAny commands you enter here will be passed directly to Terraform in your configuration path scope."
    end

    # PROCESSING INTERACTIVE COMMANDS
    #
    def process_command(raw_command)
      full_command = command(raw_command)
      @node.execute_local(full_command)
      wait_for_command_input
    end

    # HANDLING USER INPUT
    #
    def wait_for_command_input
      raw_command = wait_for_input
      unless raw_command == QUIT
        process_command(raw_command)
      end
    end
 
    def wait_for_input(message = COMMAND_PROMPT)
      ::Readline.readline("\n#{message}", true).squeeze('').to_s
    end 

    # COMMAND PROCESSING
    def terraform_metadata
      @terraform_metadata ||= @node.metadata.fetch(:terraform)
    end  

    # Get the terraform variables for this stack, and merge in with our EC2 access keys
    def form_var_string
      terraform_vars = terraform_metadata
      ec2_credentials = @node.network_driver.raw_fog_credentials

      all_vars = terraform_vars.merge({
        :access_key => ec2_credentials["aws_access_key_id"],
        :secret_key => ec2_credentials["aws_secret_access_key"]
      })

      all_vars.collect{|key, value| "-var #{key}=\"#{value}\""}.join("\s")
    end

    def var_string
      @var_string ||= form_var_string
    end

    # Retrieve the path to the terraform configurations for this stack
    def path_to_env_config
      @path_to_env_config ||= "terraform/environments/#{@node.namespace.gsub(":","_")}"
    end

    # Formulate a terraform command
    def command(raw_command)
      "cd #{path_to_env_config} ; terraform #{raw_command} #{var_string}"
    end

  end
end
