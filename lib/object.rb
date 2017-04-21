class Object

  def set_irb_prompt(conf)
    conf[:PROMPT][:CUSTOM] = {
      :PROMPT_N => "\e[1m:\e[m ",
      :PROMPT_I => "\e[1m#{::BCOME.irb_prompt} >\e[m ", # high voltage
      :PROMPT_C => "\e[1m#{::BCOME.irb_prompt} >\e[m ",
      :RETURN => ::VERBOSE ? "%s \n" : "\n"
    }
    conf[:PROMPT_MODE] = :CUSTOM
  end

end

