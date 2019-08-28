module Bcome
  module Ssh
    class TunnelKeeper

      include Singleton
    
      def initialize
        @tunnels = []
      end 

      def <<(tunnel)
        @tunnels << tunnel
      end

      def close_tunnels
        @tunnels.each {|tunnel| tunnel.close! }
      end

    end
  end
end

