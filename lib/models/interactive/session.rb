module Bcome::Interactive
  class Session

    class << self
      def run(irb_session)
        irb_pre_session_return_format = irb_session.conf.return_format
        session_end_message = "\ninteractive session ended".success
        begin
          session = ::Bcome::Interactive::Session.new(irb_session)
          irb_session.conf.return_format = ""
          system("clear")
          session.prompt
        rescue ::Bcome::Interactive::SessionHalt => e
          irb_session.conf.return_format = irb_pre_session_return_format
          puts session_end_message
        end
      end
    end

    attr_reader :responses, :irb_session

    def initialize(irb_session)
      @irb_session = irb_session
      @responses = {}
    end

    def prompt
      item = ::Bcome::Interactive::SessionItem::TransparentSsh.new(self)  
      print item.start_message
      process_item(item)
    end

    def process_item(item)
      begin
        item.do
      rescue Exception => e
        puts "Exception: #{e.message}"
        puts e.backtrace.join("\n")
        raise ::Bcome::Interactive::SessionHalt.new
      end
    end

  end
end
