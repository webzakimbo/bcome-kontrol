# frozen_string_literal: true

module Bcome::Node
  class MetaDataLoader
    include ::Singleton

    META_DATA_FILE_PATH_PREFIX = 'bcome/metadata'

    def initialize
      @all_metadata_filenames = Dir["#{META_DATA_FILE_PATH_PREFIX}/*"]
    end

    attr_reader :decryption_key

    def data
      @data ||= do_load
    end

    def data_for_namespace(namespace)
      static_data = data[namespace.to_sym] || {}
      static_data.merge(terraform_data_for_namespace(namespace))
    end

    def terraform_data_for_namespace(namespace)
      ## TODO Not sure what was being smoked, but this only adds in data for the first module
      ## Until I can fix, we will:

      parser = Bcome::Terraform::Parser.new(namespace)
      attributes = parser.attributes

      terraform_data = {}

      if attributes.keys.any?
        ## 1. Keep the old broken implementation
        terraform_data['terraform_attributes'] = attributes if attributes.keys.any?
        ## 2. But make all the data accessible
        terraform_data['tf_state'] = parser.state.config
      end

      terraform_data
    end

    def prompt_for_decryption_key
      print "\nEnter your decryption key: ".informational
      @decryption_key = STDIN.noecho(&:gets).chomp
    end

    def load_file_data_for(filepath)
      if filepath =~ /.enc/ # encrypted file contents
        prompt_for_decryption_key unless decryption_key
        encrypted_contents = File.read(filepath)
        decrypted_contents = encrypted_contents.decrypt(decryption_key)

        begin
          YAML.load(decrypted_contents)
        rescue Exception => e
          raise ::Bcome::Exception::InvalidMetaDataConfig.new "#{e.class} #{e.message} - " + decrypted_contents
        end

      else # unencrypted
        YAML.load_file(filepath)
      end
    end

    def do_load
      all_meta_data = {}
      @all_metadata_filenames.each do |filepath|
        next if filepath =~ /-unenc/ # we only read from the encrypted, packed files.

        begin
          filedata = load_file_data_for(filepath)
          all_meta_data.deep_merge!(filedata)
        rescue Psych::SyntaxError => e
          raise Bcome::Exception::InvalidMetaDataConfig, "Error: #{e.message}"
        end
      end
      all_meta_data
    end
  end
end
