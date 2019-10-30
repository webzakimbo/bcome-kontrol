# frozen_string_literal: true

module Bcome
  module LoadingBar
    module Handler
      def start_indicator(config)
        klass = config[:type] == :progress ? ::Bcome::LoadingBar::Indicator::Progress : ::Bcome::LoadingBar::Indicator::Basic
        @indicator = klass.new(config)
        fork_process
      end

      def stop_indicator
        signal_stop
      end

      def cursor
        ::TTY::Cursor
      end

      def wrap_indicator(config, &block)
        begin
          start_indicator(config)
          cursor.invisible {
            block.call
          }
        rescue IRB::Abort
          stop_indicator
          raise ::Bcome::Exception::Generic, 'Interrupt'
        rescue StandardError => e
          stop_indicator
          raise ::Bcome::Exception::Generic, e.message if config[:type] == :basic
        end
        stop_indicator
      end

      def fork_process
        @pid = fork do
          Signal.trap(::Bcome::LoadingBar::Indicator::Base::SIGNAL_SUCCESS) do
            @indicator.increment_success
          end

          Signal.trap(::Bcome::LoadingBar::Indicator::Base::SIGNAL_FAILURE) do
            @indicator.increment_failure
          end

          @indicator.indicate
        end
        ::Bcome::LoadingBar::PidBucket.instance << @pid
      end

      def do_signal(signal)
        ::Process.kill(signal, @pid)
      end

      def signal_stop
        # Stop the loader
        do_signal(::Bcome::LoadingBar::Indicator::Base::SIGNAL_STOP)

        # De-register its pid
        ::Bcome::LoadingBar::PidBucket.instance - @pid

        # Show the PARENT process indicator, which has been kept in sync with the forked process. We do this due to race condition where the forked indicator
        # does not gets final status before it is killed, so that it looks as if it has not completed
        @indicator.show
      end

      def signal_success
        do_signal(::Bcome::LoadingBar::Indicator::Base::SIGNAL_SUCCESS)
        # Keep parent indicator in sync (see #signal_stop)
        @indicator.increment_success
      end

      def signal_failure
        do_signal(::Bcome::LoadingBar::Indicator::Base::SIGNAL_FAILURE)
        # Keeo parent indicator in sync (see #signal_stop)
        @indicator.increment_failure
      end
    end
  end
end
