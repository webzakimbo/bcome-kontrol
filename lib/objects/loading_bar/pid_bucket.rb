# frozen_string_literal: true
  
module Bcome
  module LoadingBar
    class PidBucket

      include Singleton

      def initialize
        @pids = []
      end

      def <<(pid)
        @pids << pid
      end
  
      def -(pid)
        @pids = @pids - [pid]
      end

      def kill_all
        @pids.map{|pid|
          ::Process.kill(::Bcome::LoadingBar::Indicator::Base::SIGNAL_STOP, pid)
        }
      end

    end
  end
end
