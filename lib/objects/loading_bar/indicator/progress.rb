# frozen_string_literal: true

module Bcome
  module LoadingBar
    module Indicator
      class Progress < Base
        def show
          line = ''
          @results.map { |r| line += (r == 1 ? progressed_glyph.to_s.bc_green.bold : progressed_glyph.to_s.bc_red.bold) }
          line += glyph.bc_orange.to_s * (@progress_size - @results.size)
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
      end
    end
  end
end
