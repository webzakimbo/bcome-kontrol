module Bcome::Node
  class MetaDataLoader

    include ::Singleton

    META_DATA_FILE_PATH_PREFIX = "bcome/metadata".freeze

    def initialize
      @all_metadata_filenames = Dir["#{META_DATA_FILE_PATH_PREFIX}/*"]
    end

    def data
      @data ||= do_load
    end

    def data_for_namespace(namespace)
      data[namespace.to_sym] ? data[namespace.to_sym] : {}
    end

    def do_load
      all_meta_data = {}
      @all_metadata_filenames.each do |filename|
        begin
          filedata = YAML.load_file(filename).deep_symbolize_keys
          all_meta_data.merge!(filedata)
        rescue Psych::SyntaxError => e
          raise ::Bcome::Exception::InvalidMetaDataConfig.new "Error: #{e.message}"
        end
      end
      return all_meta_data
    end

  end
end
