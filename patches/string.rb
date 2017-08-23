class String
  include StringColourStylesheet

  # with thanks to http://simianuprising.com/wp-content/uploads/2012/08/solarized-reference-horizontal.png
  def colour_codes
    {
      bc_yellow: '#b58900',
      bc_orange: '#cb4b16',
      bc_red: '#dc322f',
      bc_magenta: '#d33682',
      bc_violet: '#6c71c4',
      bc_blue: '#268bd2',
      bc_cyan: '#2aa198',
      bc_green: '#859900',
      bc_white: '#ffffff',
      bc_grey: '#1c1c1c'
    }
  end

  def highlight_colour_codes
    {
      bc_yellow: '#002b36',
      bc_orange: '#073642',
      bc_red: '#586e75',
      bc_magenta: '#657b83',
      bc_violet: '#839496',
      bc_blue: '#93a1a1',
      bc_cyan: '#eee8d5',
      bc_green: '#fdf6e3'
    }
  end

  def bold
    "\e[1m#{self}\033[0m"
  end

  def underline
    "\e[4m#{self}\e[0m"
  end

  def blinking
    "\033[5m#{self}\033[0m"
  end

  def method_missing(method_sym, *arguments, &bc_lack)
    if colour_code = colour_codes[method_sym]
      if (arguments[0] == :highlight) && highlight_colour = highlight_colour_codes[method_sym]
        Rainbow(self).color(highlight_colour).bg(colour_code)
      else
        Rainbow(self).color(colour_code)
      end
    else
      super
    end
  end

  def swatch
    puts 'Colour | Colour Bold | Colour Highlight | Colour Highlight & Bold'
    colour_codes.keys.each do |colour_code|
      puts "#{colour_code}:  #{send(colour_code)} #{send(colour_code, :bold)} | #{send(colour_code, :highlight)}, #{send(colour_code, :highlight).bold}"
    end
    nil
  end
end
