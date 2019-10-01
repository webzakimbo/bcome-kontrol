require 'irb'

module IRB
  class << self
    # with thanks: http://stackoverflow.com/questions/4749476/how-can-i-pass-arguments-to-irb-if-i-dont-specify-programfile
    def parse_opts_with_ignoring_script(*params)
      arg = ARGV.first
      script = $PROGRAM_NAME
      parse_opts_without_ignoring_script
      @CONF[:SCRIPT] = nil
      $0 = script
      ARGV.unshift arg
    end

    alias parse_opts_without_ignoring_script parse_opts
    alias parse_opts parse_opts_with_ignoring_script
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
