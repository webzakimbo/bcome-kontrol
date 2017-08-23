module Bcome::Interactive
  class Session
    class << self
      def run(node, session_type, init_data = {})
        session_end_message = "\ninteractive session ended\n".informational
        begin
          session = ::Bcome::Interactive::Session.new(node, session_type_to_klass[session_type], init_data)
          session.start
        rescue ::Bcome::Exception::InteractiveSessionHalt => e
          puts session_end_message
        rescue  ::Bcome::Exception::CouldNotInitiateSshConnection => e
          puts e.message.error
        rescue ::IRB::Abort
          puts session_end_message
        end
      end

      def session_type_to_klass
        {
          interactive_ssh: ::Bcome::Interactive::SessionItem::TransparentSsh,
          capture_input: ::Bcome::Interactive::SessionItem::CaptureInput
        }
      end
    end

    attr_reader :responses, :node

    def initialize(node, item_klass, init_data)
      @item_klass = item_klass
      @node = node
      @responses = {}
      @init_data = init_data
    end

    def start
      print start_item.start_message if start_item.has_start_message?
      start_item.do
    end

    def start_item
      @start_item ||= @item_klass.new(self, @init_data)
    end
  end
end
