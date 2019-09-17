module LoadingBar
  module Handler
      
    def start_progress_indicator(progress_size, title, completed_title)
      indicator = LoadingBar::Indicator.new(
        size: progress_size,
        title: title,
        completed_title: completed_title
      )
      fork_process(indicator, :progress)
    end

    def start_basic_indicator(title, completed_title)
      indicator = LoadingBar::Indicator.new(
        title: title,
        completed_title: completed_title
      )
      fork_process(indicator, :basic)
    end
 
    def fork_process(indicator, indicator_method)
      @pid = fork do
        Signal.trap(::LoadingBar::Indicator::SIGNAL_SUCCESS) do
          indicator.increment_success
        end
        Signal.trap(LoadingBar::Indicator::SIGNAL_FAILURE) do
          indicator.increment_failure
        end
        indicator.send(indicator_method)
      end
    end  

    def do_signal(signal)
      ::Process.kill(signal, @pid)
    end

    def signal_stop
      sleep(1)
      do_signal(::LoadingBar::Indicator::SIGNAL_STOP)
    end

    def signal_success
      do_signal(::LoadingBar::Indicator::SIGNAL_SUCCESS)
    end

    def signal_failure
      do_signal(::LoadingBar::Indicator::SIGNAL_FAILURE)
    end

  end
end
