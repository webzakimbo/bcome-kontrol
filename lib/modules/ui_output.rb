module Bcome::UiOutput
  def output_error(string)
    no_console_output(string.error)
  end

  def no_console_output(string)
    puts "\t\n#{string}\n\n"
  end
end
