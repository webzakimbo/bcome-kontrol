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
      static_data = data[namespace.to_sym] ? data[namespace.to_sym] : {}
      static_data.merge(terraform_data_for_namespace(namespace))
    end

    def terraform_data_for_namespace(namespace)
      parser = Bcome::Terraform::Parser.new(namespace)
      attributes = parser.attributes
      if attributes.keys.any?
        {
          "terraform_attributes" => attributes
        }
      else
        {}
      end
    end

    def prompt_for_decryption_key
      print "\nEnter your decryption key: ".informational
      @decryption_key = STDIN.noecho(&:gets).chomp
    end

    def load_file_data_for(filepath)
     if filepath =~ /.enc/  # encrypted file contents 
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
      return all_meta_data
    end
  end
end
