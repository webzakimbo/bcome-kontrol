module Bcome::Interactive::SessionItem
  class CaptureInput < ::Bcome::Interactive::SessionItem::Base
    def do
      action
    end

    def terminal_prompt
      "\n" + @init_data[:terminal_prompt].informational
    end

    def action
      input = get_input
      input.empty? ? get_input : input
    end

    def has_start_message?
      false
    end
  end
end
