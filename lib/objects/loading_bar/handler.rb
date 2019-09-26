module Bcome
  module LoadingBar
    module Handler
      
      def start_progress_indicator(progress_size, title, completed_title)
        indicator = ::Bcome::LoadingBar::Indicator::Progress.new(
          size: progress_size,
          title: title,
          completed_title: completed_title
        )
        fork_process(indicator)
      end

      def start_basic_indicator(title, completed_title)
        indicator = ::Bcome::LoadingBar::Indicator::Basic.new(
          title: title,
          completed_title: completed_title
        )
        fork_process(indicator)
      end
 
      def fork_process(indicator)
        @pid = fork do
          Signal.trap(::Bcome::LoadingBar::Indicator::Base::SIGNAL_SUCCESS) do
            indicator.increment_success
          end
          Signal.trap(::Bcome::LoadingBar::Indicator::Base::SIGNAL_FAILURE) do
            indicator.increment_failure
          end
          indicator.indicate
        end
        ::Bcome::LoadingBar::PidBucket.instance << @pid
      end  

      def do_signal(signal)
        ::Process.kill(signal, @pid)
      end

      def signal_stop
        do_signal(::Bcome::LoadingBar::Indicator::Base::SIGNAL_STOP)
      end

      def signal_success
        do_signal(::Bcome::LoadingBar::Indicator::Base::SIGNAL_SUCCESS)
      end

      def signal_failure
        do_signal(::Bcome::LoadingBar::Indicator::Base::SIGNAL_FAILURE)
      end
    end
  end
end
