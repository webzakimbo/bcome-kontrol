module Bcome::Node::Meta
  class Base
    attr_reader :data

    def initialize(data)
      @data = data.deep_symbolize_keys
    end

    def has_key_and_value?(matchers)
      raise Bcome::Exception::InvalidMatcherQuery unless matchers[:key] && matchers[:values].is_a?(Array)
      key = matchers[:key].to_sym
      values = matchers[:values]
      @data.key?(key) && values.include?(@data[key])
    end

    def dump
      @data.each do |k, v|
        puts "#{k} => #{v.resource_value}"
      end
    end

    def fetch(key)
      key = key.to_sym

      if @data.key?(key)
        @data[key]
      else
        raise Bcome::Exception::CantFindKeyInMetadata, key unless @data.key?(key)
      end
    end
  end
end
