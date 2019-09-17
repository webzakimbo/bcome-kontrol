module LoadingBar
  class Indicator

    CHARACTERS = %w(⣾ ⣷ ⣯ ⣟ ⡿ ⢿ ⣻ ⣽)

    SIGNAL_SUCCESS = "USR1"
    SIGNAL_FAILURE = "USR2"
    SIGNAL_STOP = "HUP" 
 
    def initialize(config)
      @progress_size = config[:size]
      @title = config[:title]
      @completed_title = config[:completed_title]

      @current_character = 0
      @progression = ""
      @results = []
    end

    def basic
      print "\n"
      loop do
        increment
        print_basic
      end
    end

    def progress
      print "\n"
      loop do
        increment
        print_progress
      end
    end

    def print_basic
      print "\r#{@title}\s#{glyph.bc_green}\s"
    end

    def print_progress
      line = ""
      @results.map{|r| line += (r == 1 ? "#{progressed_glyph}".bc_green.bold : "#{progressed_glyph}".bc_red.bold ) }
      line += "#{glyph.bc_orange}" * (@progress_size - @results.size)
      print "\r#{@title}\s#{line}\s(#{@results.size}/#{@progress_size})\s"
    end

    def increment_success
      @results << 1
      @progression += progressed_glyph.bc_green.bold
    end

    def increment_failure
      @results << 0
      @progression += progressed_glyph.bc_red.bold
    end

    private

    def increment
      @current_character = @current_character + 1
      @current_character = 0 if completed_cycle?
    end

    def completed_cycle?
      @current_character == CHARACTERS.length
    end

    def progressed_glyph
      CHARACTERS[0]
    end

    def glyph
      CHARACTERS[@current_character]
    end
  end
end
