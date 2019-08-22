module ::Bcome::Ssh
  module DriverCommandStrings

    def ssh_command(as_pseudo_tty = false)
      connection_wrangler.get_ssh_command(as_pseudo_tty: as_pseudo_tty)
    end
    
    # TODO
    def rsync_command(local_path, remote_path)
      if has_proxy?
        connection_wrangler.get_rsync_command(local_path, remote_path) 
      else
        "rsync -av #{local_path} #{user}@#{@context_node.public_ip_address}:#{remote_path}"
      end
    end

    # TODO
    def local_port_forward_command(start_port, end_port)
      if has_proxy?
        "ssh -N -L #{start_port}:#{@context_node.internal_ip_address}:#{end_port} #{bastion_host_user}@#{@proxy_data.host}"
      else
        "ssh -N -L #{start_port}:#{@context_node.public_ip_address}:#{end_port}"
     end
    end

  end
end
