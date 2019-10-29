module Bcome
  class Startup

    def initialize(breadcrumbs, arguments)
      @breadcrumbs = breadcrumbs
      @arguments = arguments
    end

    def do
      case @breadcrumbs
      when "-v", "--version", "--v"
        puts ::Bcome::Version.display
      when "pack_metadata"
        ::Bcome::Encryptor.instance.pack
      when "unpack_metadata"
        ::Bcome::Encryptor.instance.unpack
      else
        bootup
      end
    end

    def bootup
      begin
        spawn_into_console = true
        ::Bcome::Bootup.set_and_do({ breadcrumbs: @breadcrumbs, arguments: @arguments }, spawn_into_console)
        clean_up
      rescue ::Bcome::Exception::Base => e
        clean_up
        puts e.pretty_display
      rescue Excon::Error::Socket => e
        clean_up
        puts "\nNo network access - please check your connection and try again\n".error
      rescue Exception => e
        clean_up
        raise e
      end
    end

    def clean_up
      stop_loading_bars
      close_connections
    end

    def close_connections
      ::Bcome::Bootup.instance.close_ssh_connections
      ::Bcome::Ssh::TunnelKeeper.instance.close_tunnels
    end

    def stop_loading_bars
      ::Bcome::LoadingBar::PidBucket.instance.stop_all
    end

  end
end
