module Bcome::Registry::Command
  class Base
    class << self
      def new_from_raw_command(data)
        raise Bcome::Exception::InvalidContextCommand, "#{data.inspect} is missing key type" unless data[:type]
        raise Bcome::Exception::InvalidContextCommand, "#{data.inspect} has invalid type '#{data[:type]}'" unless is_valid_type?(data[:type])
        valid_types[data[:type].to_sym].new(data)
      end

      def is_valid_type?(type)
        valid_types.keys.include?(type.to_sym)
      end

      def valid_types
        {
          external: ::Bcome::Registry::Command::External,
          internal: ::Bcome::Registry::Command::Internal
        }
      end
    end

    def initialize(data)
      @data = data
      @data[:defaults] = {} unless @data[:defaults]
      validate
    end

    def process_arguments(arguments)
      merged_arguments = {}

      if [Array, Hash].include?(arguments.class)
        processor_klass = arguments.is_a?(Array) ? ::Bcome::Registry::Arguments::CommandLine : ::Bcome::Registry::Arguments::Console
        merged_arguments = processor_klass.process(arguments, defaults)
      elsif defaults
        merged_arguments = defaults
      end
      merged_arguments
    end

    def execute(*_params)
      raise 'Should be overriden'
    end

    def expected_keys
      %i[console_command group description]
    end

    def method_missing(method_sym, *arguments, &block)
      @data.key?(method_sym) ? @data[method_sym] : super
    end

    def pretty_print
      puts do_pretty_print
    end

    def do_pretty_print
      menu_str = "\s\s\s\s" + "command:\s".resource_key + console_command.underline.resource_value
      menu_str += "\n\s\s\s\s" + "description:\s".resource_key + description.resource_value + "\n\n"
    end

    def validate
      expected_keys.each do |key|
        validation_error "#{@data.inspect} is missing key #{key}" unless @data.key?(key)
      end
    end

    def validation_error(message)
      raise Bcome::Exception::InvalidContextCommand, message
    end
  end
end
