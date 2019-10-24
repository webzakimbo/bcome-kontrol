# frozen_string_literal: true

module Bcome::Registry::Arguments
  class CommandLine < Base
    def initialize(arguments, defaults)
      @arguments = arguments || []
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
      @arguments.each do |argument|
        argument =~ /^(.+)=(.+)$/
        raise Bcome::Exception::MalformedCommandLineArguments, argument unless Regexp.last_match(1) || Regexp.last_match(2)

        key = Regexp.last_match(1).to_sym; value = Regexp.last_match(2)
        raise Bcome::Exception::DuplicateCommandLineArgumentKey, "'#{key}'" if @processed_arguments.key?(key)

        @processed_arguments[key] = value
      end
    end

    def validate
      raise Bcome::Exception::InvalidRegistryArgumentType, 'invalid argument format' unless @arguments.is_a?(Array)

      super
    end
  end
end
