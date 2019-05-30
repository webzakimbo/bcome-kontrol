# frozen_string_literal: true

module Bcome
  module UiOutput
    def output_error(string)
      no_console_output(string.error)
    end

    def no_console_output(string)
      puts "\t\n#{string}\n\n"
    end
  end
end
