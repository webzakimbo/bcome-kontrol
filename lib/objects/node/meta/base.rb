# frozen_string_literal: true

module Bcome::Node::Meta
  class Base
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def has_key_and_value?(matchers)
      matchers[:values] = [matchers[:values]] if matchers[:values] && !matchers[:values].is_a?(Array)

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

    def all
      @data
    end

    def fetch(key, default = nil)
      if @data.key?(key)
        @data[key]
      elsif default
        default
      else
        raise Bcome::Exception::CantFindKeyInMetadata, key unless @data.key?(key)
      end
    end
  end
end
