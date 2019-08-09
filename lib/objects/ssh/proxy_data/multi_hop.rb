# frozen_string_literal: true
  
module Bcome::Ssh::ProxyData
  class MultiHop

    attr_reader :proxy_data_collection
    attr_reader :context_node

    def initialize(config, context_node)
      @config = config
      @context_node = context_node
      @proxy_data_collection = []
      set_proxy_data
    end

    def set_proxy_data
      @config.each do |config|
        @proxy_data_collection << ::Bcome::Ssh::ProxyData::SingleHop.new(config, @context_node)
      end
    end

  end
end
