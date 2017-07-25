module Bcome::Node::Meta
  class Base

    attr_reader :data
  
    def initialize(data)
      @data = data.deep_symbolize_keys
    end

    def has_key_and_value?(matchers)
      raise ::Bcome::Exception::InvalidMatcherQuery.new unless matchers[:key] && matchers[:values].is_a?(Array)
      key = matchers[:key].to_sym
      values = matchers[:values]
      return @data.has_key?(key) && values.include?(@data[key])
    end

    def dump
      @data.each do |k, v|
        puts "#{k} => #{v.resource_value}"
      end
    end

    def fetch(key)
      key = key.to_sym

      if @data.has_key?(key)
        @data[key]
      else
        raise ::Bcome::Exception::CantFindKeyInMetadata.new key unless @data.has_key?(key)
      end
    end

  end
end
