# frozen_string_literal: true

## Kubectl command wrapper. This will integrate directly with bcome's GCP authentication driver
class KubeWrap
  KUBE_BIN = 'kubectl'

  def initialize(access_token)
    @access_token = access_token
  end

  def run(command_suffix)
    full_command = create_command_for(command_suffix)
    result = ::Bcome::Command::Local.run(full_command)

    if result.failed?
      puts "\n" + result.stderr.error + "\n"
      raise
    end

    result
  end

  def create_command_for(suffix)
    "#{KUBE_BIN} --token #{@access_token} #{suffix}"
  end
end
