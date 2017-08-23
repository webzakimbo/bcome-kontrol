module Bcome::Registry::Arguments

  class CommandLine < Base

    def initialize(arguments, defaults)
      @arguments = arguments ? arguments : []
      @processed_arguments = {}
      super
    end

    def do_process
      parse_arguments
      super
    end

    def arguments_to_merge
      @processed_arguments
    end

    private

    def parse_arguments
      @arguments.each {|argument|
        argument =~ /^(.+)=(.+)$/
        raise ::Bcome::Exception::MalformedCommandLineArguments.new argument unless $1 || $2
        key = $1.to_sym ; value = $2
        raise ::Bcome::Exception::DuplicateCommandLineArgumentKey.new "'#{key}'" if @processed_arguments.has_key?(key)
        @processed_arguments[key] = value
      }
    end

    def validate
      raise ::Bcome::Exception::InvalidRegistryArgumentType.new "invalid argument format" unless @arguments.is_a?(Array)
      super
    end

  end
end
