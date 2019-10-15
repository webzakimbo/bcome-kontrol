# frozen_string_literal: true

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
        @tunnels.each(&:close!)
      end
    end
  end
end
