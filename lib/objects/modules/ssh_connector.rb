module Bcome
  module SshConnector
  
    SIGNAL_SUCCESS = "USR1"
    SIGNAL_FAILURE = "USR2"
    SIGNAL_STOP = "HUP" 

    def global_connect

      ## Fork a progress loader, but retain its pid so we can increment it
      progress_size = machines.size
      indicator = LoadingBar::Indicator.new( 
        size: progress_size,
        title: "connecting",
        completed_title: "done"
      )

      @pid = fork do
        Signal.trap(SIGNAL_SUCCESS) do
          indicator.increment_success
        end

        Signal.trap(SIGNAL_FAILURE) do
          indicator.increment_failure
        end

        indicator.progress
        #puts "\n\sdone".informational
      end

      machines.pmap do |machine|
        if machine.has_ssh_connection?
          signal_success
        else
          machine.open_ssh_connection  
          machine.has_ssh_connection? ? signal_success : signal_failure
        end
      end

      signal_stop
    end

    def do_signal(signal)
      ::Process.kill(signal, @pid)
    end

    def signal_stop
      do_signal(SIGNAL_STOP)
      print "done".informational
    end

    def signal_success
      do_signal(SIGNAL_SUCCESS)
    end

    def signal_failure
      do_signal(SIGNAL_FAILURE)
    end

  end
end
