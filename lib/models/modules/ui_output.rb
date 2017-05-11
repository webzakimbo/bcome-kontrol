module Bcome::UiOutput
  def output_error(string)
    no_console_output(string.bc_red)
  end

  def no_console_output(string)
    puts "\t\n#{string}\n\n"
  end
end
