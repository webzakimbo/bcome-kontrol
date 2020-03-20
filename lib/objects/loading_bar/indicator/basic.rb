# frozen_string_literal: true

module Bcome
  module LoadingBar
    module Indicator
      class Basic < Base
        def initialize(*params)
          super
          @progress_colour = :bc_green
        end

        def show(done = false)
          print "\r#{progress_prefix}#{done ? "\s#{@completed_title}\s" : ''}\s"
        rescue ThreadError
        end

        def progress_prefix
          "#{@title}\s#{glyph.send(progress_colour)}"
        end

        attr_reader :progress_colour

        def increment_success
          done = true
          show(done)
        end

        def increment_failure
          @progress_colour = :bc_red
        end
      end
    end
  end
end
