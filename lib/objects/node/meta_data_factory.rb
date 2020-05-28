# frozen_string_literal: true

module Bcome::Node::LocalMetaDataFactory
  META_DATA_FILE_PATH_PREFIX = 'bcome/metadata'

  def metadata
    @node_metadata ||= do_create_metadata
  end

  def do_create_metadata
    ::Bcome::Node::Meta::Local.new(raw_metadata)
  end

  def meta
    data_print_from_hash(raw_metadata, 'Metadata')
  end

  def raw_metadata
    has_parent? ? parent.raw_metadata.deep_merge(metadata_for_namespace) : metadata_for_namespace
  end

  def metadata_for_namespace
    ::Bcome::Node::MetaDataLoader.instance.data_for_namespace(namespace)
  end
end
