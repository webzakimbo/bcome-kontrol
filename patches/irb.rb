require 'irb'

module IRB
  class << self
    # http://stackoverflow.com/questions/4749476/how-can-i-pass-arguments-to-irb-if-i-dont-specify-programfile
    def parse_opts_with_ignoring_script
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
end
