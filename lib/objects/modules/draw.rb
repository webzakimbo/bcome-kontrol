module Bcome
  module Draw

    # see: https://en.wikipedia.org/wiki/Box-drawing_character

    ## Tree shapes
    BOTTOM_ANCHOR = "└───╸"
    MID_SHIPS = "├───╸"
    BRANCH = "│"
    LEFT_PADDING = "\s" * 6
    INGRESS = "│"
    BLIP = "▐▆"
    
    ## Box shapes
    BOX_SIDE = "│"
    BOX_TOP_LEFT = "┌"
    BOX_TOP_RIGHT = "┐"
    BOX_BOTTOM_LEFT = "└"
    BOX_BOTTOM_RIGHT = "┘"
    BOX_HORIZONTAL_LINE = "─"

    # Takes an array of strings, each representing a line
    # Draws a box around the lines, and returns a new array
    # padding may be provided
    def box_it(array_of_lines, padding = 1, box_colour = :bc_cyan)
      max_length = max_box_line_length(array_of_lines)
      pad_string = "\s" * padding

      box_lines = [
        # Set the top box line
        "#{BOX_TOP_LEFT}#{BOX_HORIZONTAL_LINE * (max_length + (padding + 1))}#{BOX_TOP_RIGHT}"
      ]

      array_of_lines.each do |line|
        line_length = line.sanitize.length
        box_lines << "#{BOX_SIDE}#{pad_string}" + "#{line}" + "#{"\s" * (max_length - line_length)}#{pad_string}#{BOX_SIDE}"
      end      

      # Set the bottom box line
      box_lines << "#{BOX_BOTTOM_LEFT}#{BOX_HORIZONTAL_LINE * (max_length + (padding + 1))}#{BOX_BOTTOM_RIGHT}"
      return box_lines
    end

    def max_box_line_length(array_of_lines)
      array_of_lines.max_by{|string| string.sanitize.length }.sanitize.length
    end  
  end
end
