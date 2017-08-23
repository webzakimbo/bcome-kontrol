module Bcome::Registry::Arguments
  class Base
    attr_reader :arguments, :defaults, :processed_arguments, :merged_arguments

    class << self
      def process(arguments, defaults)
        processor = new(arguments, defaults)
        processor.do_process
      end
    end

    def initialize(_arguments, defaults)
      @defaults = defaults ? defaults : {}
      validate
    end

    def do_process
      merge_arguments_with_defaults
      @merged_arguments
    end

    private

    def merge_arguments_with_defaults
      @merged_arguments = @defaults.symbolize_keys.merge(arguments_to_merge.symbolize_keys)
    end

    def arguments_to_merge
      @arguments
    end

    def validate
      raise Bcome::Exception::InvalidRegistryArgumentType, 'invalid default registry argument format' unless @defaults.is_a?(Hash)
    end
  end
end
