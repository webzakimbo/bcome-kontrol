module Bcome::Interactive::SessionItem
  class CaptureInput < ::Bcome::Interactive::SessionItem::Base

    def do
      return action
    end

    def terminal_prompt
      "enter manifest file name or hit enter to save as existing (#{display_file_name}): ".bc_magenta
    end

    def display_file_name
      @init_data[:current_filename] =~ /(.+)\.yml/
      return $1
    end

    def action
      input = get_input
      return input.empty? ? @init_data[:current_filename] : "#{input}.yml" 
    end

    def start_message
      "\n" + @init_data[:start_message].bc_yellow.bold
    end

  end
end
