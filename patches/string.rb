class String

  # Simple palette with bold & background highlighting
  # usage: "Foo bar".cyan
  #        "Foo bar".cyan.bold
  #        "Foo bar".cyan(:highlight)
  #        "Foo bar".cyan(:highlight).bold


  # with thanks to http://simianuprising.com/wp-content/uploads/2012/08/solarized-reference-horizontal.png
  def colour_codes
    {
      :yellow => "#b58900",
      :orange => "#cb4b16",
      :red => "#dc322f",
      :magenta => "#d33682",
      :violet => "#6c71c4",
      :blue => "#268bd2",
      :cyan => "#2aa198",
      :green => "#859900",
      :white => "#ffffff"
    }
  end

  def highlight_colour_codes
    {
      :yellow => "#002b36",
      :orange => "#073642",
      :red => "#586e75",
      :magenta => "#657b83",
      :violet => "#839496",
      :blue => "#93a1a1",
      :cyan => "#eee8d5",
      :green => "#fdf6e3"
    }
  end

  def bold
    return "\e[1m#{self}\033[0m"
  end

  def method_missing(method_sym, *arguments, &black)
    unless colour_code = colour_codes[method_sym]
      super
    else
      if (arguments[0] == :highlight) && highlight_colour = highlight_colour_codes[method_sym]
        return Rainbow(self).color(highlight_colour).bg(colour_code)
      else
        return Rainbow(self).color(colour_code)
      end
    end
  end

  def swatch
    puts "Colour | Colour Bold | Colour Highlight | Colour Highlight & Bold"
    colour_codes.keys.each do |colour_code|
      puts "#{colour_code}:  #{send(colour_code)} #{send(colour_code, :bold)} | #{send(colour_code, :highlight)}, #{send(colour_code, :highlight).bold}"
    end
  end
end
