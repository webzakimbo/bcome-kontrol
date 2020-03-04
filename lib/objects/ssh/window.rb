module Bcome
  module Ssh
    class Window

      attr_reader :lines

      include Singleton

      def initialize(*params)
        @lines = []
      end

      def add(node, log_line)
        multi_line = (log_line =~ /\n/) ? true : false

        if ::Bcome::Orchestrator.instance.is_multi_node?
          @lines << "\n#{node.namespace}".terminal_prompt + "\n#{log_line}"
        else
          @lines << log_line
        end

        pop
      end
 
      def pop
        print @lines.pop
      end  

    end
  end
end
