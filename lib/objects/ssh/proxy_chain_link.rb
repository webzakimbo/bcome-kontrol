# frozen_string_literal: true

module Bcome::Ssh
  class ProxyChainLink
    attr_reader :link

    def initialize(node)
      @link = {}
      init(node.machines)
    end

    protected

    def init(machines)
      machines.each do |machine|
        proxy_chain = machine.proxy_chain
        if key = @link.keys.detect{|key| key.eql?(proxy_chain)}
          @link[key] << machine
        else
          @link[proxy_chain] = [machine]
        end
      end
    end
  end
end
