module ::Bcome::Ssh
  module DriverCommandStrings

    def proxy_connection_string
      connection_wrangler.get_proxy_connection
    end

    def bootstrap_proxy_connection_string
      "ssh -i #{@bootstrap_settings.ssh_key_path} -o StrictHostKeyChecking=no -W %h:%p #{@bootstrap_settings.bastion_host_user}@#{@proxy_data.host}"
    end

    def ssh_command(as_pseudo_tty = false)
      # TODO
      return bootstrap_ssh_command if bootstrap? && @bootstrap_settings.ssh_key_path

      connection_wrangler.get_ssh_command(as_pseudo_tty: as_pseudo_tty)
    end

    def bootstrap_ssh_command
      if has_proxy?
        "ssh -i #{@bootstrap_settings.ssh_key_path} -t #{bastion_host_user}@#{@proxy_data.host} ssh -t #{user}@#{@context_node.internal_ip_address}"
      else
        "ssh -i #{@bootstrap_settings.ssh_key_path} #{user}@#{@context_node.public_ip_address}"
      end
    end

    def rsync_command(local_path, remote_path)
      return bootstrap_rsync_command(local_path, remote_path) if bootstrap? && @bootstrap_settings.ssh_key_path

      if has_proxy?
        connection_wrangler.get_rsync_command(local_path, remote_path) 
      else
        "rsync -av #{local_path} #{user}@#{@context_node.public_ip_address}:#{remote_path}"
      end
    end

    def bootstrap_rsync_command(local_path, remote_path)
      if has_proxy?
        "rsync -av -e \"ssh -i #{@bootstrap_settings.ssh_key_path} -A #{bastion_host_user}@#{@proxy_data.host} ssh -o StrictHostKeyChecking=no\" #{local_path} #{user}@#{@context_node.internal_ip_address}:#{remote_path}"
      else
        "rsync -i #{@bootstrap_settings.ssh_key_path} -av #{local_path} #{user}@#{@context_node.public_ip_address}:#{remote_path}"
      end
    end

    def local_port_forward_command(start_port, end_port)
      if has_proxy?
        if bootstrap?
          "ssh -N -L #{start_port}:#{@context_node.internal_ip_address}:#{end_port} -i #{@bootstrap_settings.ssh_key_path} #{bastion_host_user}@#{@proxy_data.host}"
        else
          "ssh -N -L #{start_port}:#{@context_node.internal_ip_address}:#{end_port} #{bastion_host_user}@#{@proxy_data.host}"
        end
      else
       if bootstrap?
         "ssh -i #{@bootstrap_settings.ssh_key_path} -N -L #{start_port}:#{@context_node.public_ip_address}:#{end_port}"
       else
         "ssh -N -L #{start_port}:#{@context_node.public_ip_address}:#{end_port}"
       end
     end
    end

  end
end
