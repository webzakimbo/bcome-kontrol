# frozen_string_literal: true

module Bcome
  module LoadingBar
    module Indicator
      class Base
        CHARACTERS = %w[⣾ ⣷ ⣯ ⣟ ⡿ ⢿ ⣻ ⣽].freeze

        SIGNAL_SUCCESS = 'USR1'
        SIGNAL_FAILURE = 'USR2'
        SIGNAL_STOP = 'SIGKILL'

        def initialize(config = {})
          @progress_size = config[:size]
          @title = config[:title]
          @completed_title = config[:completed_title]

          @current_character = 0
          @progression = ''
          @results = []
        end

        def indicate
          print "\n"
          loop do
            increment
            show
            break if @stop
          end
        end

        def show
          raise 'Should be overidden'
        end

        def increment_success
          raise 'Should be overidden'
        end

        def increment_failure
          raise 'Should be overidden'
        end

        private

        def increment
          @current_character += 1
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
  end
end
