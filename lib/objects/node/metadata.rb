module Bcome::Node
  class Metadata

    def initialize(data)
      @data = data.deep_symbolize_keys
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
