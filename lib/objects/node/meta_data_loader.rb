# frozen_string_literal: true

module Bcome::Node
  class MetaDataLoader
    include ::Singleton

    META_DATA_FILE_PATH_PREFIX = 'bcome/metadata'

    def initialize
      @all_metadata_filenames = Dir["#{META_DATA_FILE_PATH_PREFIX}/*"]
    end

    attr_accessor :decryption_key

    def data
      @data ||= do_load
    end

    def data_for_namespace(namespace)
      static_data = data[namespace.to_sym] || {}
      static_data.merge(terraform_data_for_namespace(namespace))
    end

    def terraform_data_for_namespace(namespace)
      parser = Bcome::Terraform::Parser.new(namespace)
      attributes = parser.attributes

      terraform_data = {}

      if attributes&.keys&.any?
        # Radical departure, this makes way more sense than previous:
        # Make the entire state accessible
        terraform_data['terraform_tf_state'] = parser.state.config
        # And provide a convenience accessor for our outputs
        terraform_data['terraform_outputs'] = parser.state.config['outputs']
     end

      terraform_data
    end

    def prompt_for_decryption_key
      decryption_key_prompt = 'Enter your metadata decryption key: '.informational

      print "\n#{decryption_key_prompt}"
      @decryption_key = STDIN.noecho(&:gets).chomp
      print "\r#{decryption_key_prompt}" + "**********\n\n"
    end

    def load_file_data_for(filepath)
      if filepath =~ /.enc/ # encrypted file contents
        prompt_for_decryption_key unless decryption_key
        encrypted_contents = File.read(filepath)
        decrypted_contents = encrypted_contents.decrypt(decryption_key)

        begin
          YAML.load(decrypted_contents) # NOTE: safe_load is buggy and incorrectly parses the yaml. 
        rescue Exception => e
          @decryption_key = nil
          raise ::Bcome::Exception::InvalidMetaDataConfig, "#{e.class} #{e.message} - " + decrypted_contents
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
