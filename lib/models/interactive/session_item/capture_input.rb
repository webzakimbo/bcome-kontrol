module Bcome::Interactive::SessionItem
  class CaptureInput < ::Bcome::Interactive::SessionItem::Base

    def do
      return action
    end

    def terminal_prompt
      "enter save file name or hit enter to save as existing (#{@init_data[:current_filename]}): ".bc_yellow
    end

    def action
      input = get_input
      return input.empty? ? @init_data[:current_filename] : input
    end

    def start_message
      "\n\n" + @init_data[:start_message].bc_green + "\n"
    end

  end
end
