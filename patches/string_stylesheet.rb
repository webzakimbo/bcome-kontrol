module StringColourStylesheet

  def error
    self.bc_red.bold
  end

  def disabled
    self.bc_white
  end

  def title
    self.bc_cyan.underline
  end

  def warning
    self.bc_orange.bold
  end

  def resource_key
    self.bc_white
  end

  def resource_key_inactive
    self.bc_grey
  end

  def resource_value_inactive
    self.bc_grey
  end

  def resource_value
    self.bc_green
  end

  def hierarchy
    self.bc_green.bold
  end

  def informational
    self.bc_blue
  end

  def instructional
    self.bc_magenta
  end

  def terminal_prompt
    self.bc_cyan
  end
  
  def progress
    self.bc_green
  end

  def success
    self.bc_green
  end

  def namespace
    self.bc_cyan
  end


end
