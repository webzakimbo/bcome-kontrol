module ::Bcome::Ssh
  module DriverCommandStrings

    def ssh_command(as_pseudo_tty = false)
      connection_wrangler.get_ssh_command(as_pseudo_tty: as_pseudo_tty)
    end
    
    def rsync_command(local_path, remote_path)
      connection_wrangler.get_rsync_command(local_path, remote_path) 
    end

    def local_port_forward_command(start_port, end_port)
      connection_wrangler.get_local_port_forward_command(start_port, end_port)
    end

  end
end
