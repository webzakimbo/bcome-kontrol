# frozen_string_literal: true

## Bcome's kubernetes node namespaces
module Bcome::Node
  module Kube
    class Base
      attr_reader :resources

      def initialize(kube_wrap, config = {})
        @kube_wrap = kube_wrap
        @config = config
        @resources = []
      end

      def parent
        @config[:parent]
      end

      def run(command)
        @kube_wrap.run(command)
      end

      def build
        child_node_lookup_result = run(get_child_node_command)
        parse(child_node_lookup_result)
      end

      def parse(child_node_lookup_result)
        # Get the output
        output = child_node_lookup_result.stdout
        # Remove the title & form array
        data = output.remove_lines(1).split("\n")

        structured_data = {}
        data.each do |raw_namespace_line|
          child_config = get_child_config_from_line(raw_namespace_line)
          child_config.merge!(parent: self)
          @resources << child_node_klass.new(@kube_wrap, child_config)
        end
      end

      def get_child_node_command
        raise 'should be overriden'
      end

      def get_child_config_from_line(*_params)
        raise 'should be overidden'
      end
    end
  end
end
