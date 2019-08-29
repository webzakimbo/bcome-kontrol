module Bcome
  module Loader
    class Spinner

      include Singleton
      include InterruptibleSleep

      GLYPHS = %w(⣾ ⣷ ⣯ ⣟ ⡿ ⢿ ⣻ ⣽).reverse
      INTERVAL_DURATION = 0.05

      class << self
        def show_progress(&block)
          process = fork(&block)

          progress = fork do
            Spinner.instance.progress
          end

          Process.wait(process)
          Process.kill("HUP", progress)
          print "\r"
        end
      end

      def initialize
        @current_glyph = 0
      end

      def progress
        prefix = ""

        loop do
          increment
          print "\r#{glyph} "
          interruptible_sleep(INTERVAL_DURATION)
        end
      end

      def stop
        print "\r"
        interrupt_sleep
      end

      private

      def increment
        @current_glyph = @current_glyph + 1
        @current_glyph = 0 if @current_glyph >= GLYPHS.length
      end

      def glyph
       GLYPHS[@current_glyph]
      end
    end

  end
end
