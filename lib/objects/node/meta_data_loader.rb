module Bcome::Node
  class MetaDataLoader
    include ::Singleton

    META_DATA_FILE_PATH_PREFIX = 'bcome/metadata'.freeze

    def initialize
      @all_metadata_filenames = Dir["#{META_DATA_FILE_PATH_PREFIX}/*"]
    end

    def decryption_key
      @decryption_key
    end
 
    def data
      @data ||= do_load
    end

    def data_for_namespace(namespace)
      data[namespace.to_sym] ? data[namespace.to_sym] : {}
    end

    def prompt_for_decryption_key
      message = "Please enter your metadata encryption key: ".informational
      @decryption_key = ::Readline.readline("\n#{message}", true).squeeze('').to_s
    end

    def load_file_data_for(filepath)
      if filepath =~ /-enc/  # encrypted file contents 
        prompt_for_decryption_key unless decryption_key
        encrypted_contents = File.read(filepath)     
        decrypted_contents = encrypted_contents.decrypt(decryption_key) 
        return YAML.load(decrypted_contents)
      else # unencrypted
        return YAML.load_file(filepath)
      end
    end

    def do_load
      all_meta_data = {}
      @all_metadata_filenames.each do |filepath|
        next if filepath =~ /-unenc/  # we only read from the encrypted, packed files. 

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
