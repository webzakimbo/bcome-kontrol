module Bcome
  module LoadingBar
    module Indicator
      class Basic < Base

        def initialize(*params)
          super 
          @progress_colour = :bc_green
        end

        def show(done = false)
          print "\r#{progress_prefix}#{done ? "\s#{@completed_title}\s" : ""}\s"
        end

        def progress_prefix
          "\s#{@title}\s#{glyph.send(progress_colour)}"
        end

        def progress_colour
          @progress_colour
        end
 
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
