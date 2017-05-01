require 'irb'

module IRB
  class << self
    # http://stackoverflow.com/questions/4749476/how-can-i-pass-arguments-to-irb-if-i-dont-specify-programfile
    def parse_opts_with_ignoring_script
      arg = ARGV.first
      script = $0
      parse_opts_without_ignoring_script
      @CONF[:SCRIPT] = nil
      $0 = script
      ARGV.unshift arg
    end

    alias_method :parse_opts_without_ignoring_script, :parse_opts
    alias_method :parse_opts, :parse_opts_with_ignoring_script
  end
end
