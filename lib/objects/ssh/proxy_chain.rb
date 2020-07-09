# frozen_string_literal: true

module Bcome::Ssh
  class ProxyChain

    attr_reader :hops
   
    def initialize(wrangler)
      @hops = wrangler.hops
    end

    def eql?(other_chain)
      hops == other_chain.hops
    end

    def ==(other_chain)
      eql?(other_chain)
    end

  end
end
