module Bcome::Registry::Arguments
  class Base

    class << self
      def process(arguments, defaults)
        processor = new(arguments, defaults)
        processor.do_process
      end 
    end

    def initialize(arguments, defaults)
      @arguments = arguments
      @defaults = defaults
    end

    def do_process
      puts @arguments.inspect
      puts @defaults.inspect
    end


  end
end
