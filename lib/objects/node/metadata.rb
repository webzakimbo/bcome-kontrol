module Bcome::Node
  class Metadata

    def initialize(data)
      @data = data
    end

    def fetch(key)
      if @data.has_key?(key)
        @data[key]
      else
        raise ::Bcome::Exception::CantFindKeyInMetadata.new key unless @data.has_key?(key)
      end
    end

  end
end
