module Bcome
  module Loader
    module InterruptibleSleep
      def interruptible_sleep(seconds)
        @sleep_check, @sleep_interrupt = IO.pipe
        IO.select([@sleep_check], nil, nil, seconds)
      end

      def interrupt_sleep
        @sleep_interrupt.close if @sleep_interrupt
      end
    end
  end
end
