module Bcome::Node::MetaDataFactory

  META_DATA_FILE_PATH_PREFIX = "config/bcome/metadata".freeze

  def load_metadata
    @metadata = load_metadata_from_file if metadata_exists?
  end

  def metadata
    @node_metadata ||= do_create_metadata
  end

  def do_create_metadata
    return ::Bcome::Node::Metadata.new(raw_metadata)
  end

  def raw_metadata
    has_parent? ? parent.raw_metadata.merge(@metadata)  : @metadata
  end

  def meta_data_file_path
    "#{META_DATA_FILE_PATH_PREFIX}/#{meta_data_file_name}"
  end

  def metadata_exists?
    File.exist?(meta_data_file_path)
  end  

  def load_metadata_from_file
    begin
      config = YAML.load_file(meta_data_file_path).deep_symbolize_keys
      return config
    rescue 
      raise Bcome::Exception::InvalidMetaDataConfig, meta_data_file_name
    end
  end

  def meta_data_file_name
    "#{self.namespace}.yml"
  end

end

