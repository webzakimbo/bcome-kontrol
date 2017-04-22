module Bcome::ConsoleColours

  # see patches/string.rb for implementation details
 
  # Interface:
  # string.color_code
  # string.colour_code.bold
  # string.colour_code(:highlight)
  # string.colour_code(:highlight).bold

  # Example:  "foo bar".cyan / "foo bar".cyan.bold / "foo bar".cyan(:highlight) / "foo bar".cyan(:highlight).bold

  # example colours: yellow, orange, red, magenta, violet, blue, cyan, green, white

  # Output all colours: "foo bar".swatch

  def view_title(string)
    string.yellow.bold
  end

end
