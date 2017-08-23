module StringColourStylesheet
  def error
    bc_red.bold
  end

  def disabled
    bc_white
  end

  def title
    bc_cyan.underline
  end

  def warning
    bc_orange.bold
  end

  def resource_key
    bc_white
  end

  def resource_key_inactive
    bc_grey
  end

  def resource_value_inactive
    bc_grey
  end

  def resource_value
    bc_green
  end

  def hierarchy
    bc_green.bold
  end

  def informational
    bc_blue
  end

  def instructional
    bc_magenta
  end

  def terminal_prompt
    bc_cyan
  end

  def progress
    bc_green
  end

  def success
    bc_green
  end

  def namespace
    bc_cyan
  end
end
