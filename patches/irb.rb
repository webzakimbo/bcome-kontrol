# frozen_string_literal: true
require 'irb'
module IRB
  class << self

    # with thanks: http://stackoverflow.com/questions/4749476/how-can-i-pass-arguments-to-irb-if-i-dont-specify-programfile
    def parse_opts_with_ignoring_script(*_params)
      arg = ARGV.first
      script = $PROGRAM_NAME
      parse_opts_without_ignoring_script
      @CONF[:SCRIPT] = nil
    
      @CONF[:IGNORE_SIGINT] = true

      $0 = script
      ARGV.unshift arg
    end
    alias parse_opts_without_ignoring_script parse_opts
    alias parse_opts parse_opts_with_ignoring_script

    def start_session(bc_workspace, binding)
      workspace = WorkSpace.new(binding)

      IRB.conf[:PROMPT][:CUSTOM] = {
        PROMPT_N: "\e[1m:\e[m ",
        PROMPT_I: "\e[1m#{bc_workspace.irb_prompt} >\e[m ",
        PROMPT_C: "\e[1m#{bc_workspace.irb_prompt} >\e[m ",
        RETURN: "%s \n"
      }
      IRB.conf[:PROMPT_MODE] = :CUSTOM

      irb = Irb.new(workspace)

      @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
      @CONF[:MAIN_CONTEXT] = irb.context
  
      catch(:IRB_EXIT) do
        irb.eval_input
      end
    end
  end

  class Context
    def overriden_evaluate(*_params)
      evaluate_without_overriden(*_params)
    rescue ::Bcome::Exception::Base => e
      puts e.pretty_display
    end

    alias evaluate_without_overriden evaluate
    alias evaluate overriden_evaluate
  end # end class Context
end # end module IRB --
