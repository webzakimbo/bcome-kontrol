module Bcome
  class Encryptor

    UNENC_SIGNIFIER = "".freeze  
    ENC_SIGNIFIER = "enc".freeze

    include Singleton

    attr_reader :key

    def pack
      # Bcome currently works with a single encryption key - the same one - for all files
      # When we attempt an encrypt we'll check first to see if any encrypted files already exists, and
      # we'll try our key on it. If the fails to unpack the file, we abort the encryption attempt.
      prompt_for_key
      if has_files_to_encrypt?
        verify_presented_key if has_encrypted_files?
        toggle_packed_files(all_unencrypted_filenames, :encrypt)
      else
        puts "\nNo unencrypted files to encrypt.\n".warning
      end
      return
    end

    def prompt_for_key
      message = "Please enter an encryption key (and if your data is already encrypted, you must provide the same key): ".informational
      @key = ::Readline.readline("\n#{message}", true).squeeze('').to_s
      puts "\n"
    end

    def has_encrypted_files?
      all_encrypted_filenames.any?
    end

    def has_files_to_encrypt?
      all_unencrypted_filenames.any?
    end

    def verify_presented_key
      # We attempt a decrypt of any encrypted file in order to verify that a newly presented key
      # matches the key used to previously encrypt. Bcome operates on a one-key-per-implementation basis.
      test_file = all_encrypted_filenames.first
      file_contents = File.read(test_file)
      file_contents.decrypt(@key)
    end

    def unpack
      prompt_for_key
      toggle_packed_files(all_encrypted_filenames,:decrypt)
      return
    end

    def toggle_packed_files(filenames, packer_method)
      raise "Missing encryption key. Please set an encryption key" unless @key
      filenames.each do |filename|
        # Get raw
        raw_contents = File.read(filename)
 
        if packer_method == :decrypt
          filename =~ /#{path_to_metadata}\/(.+)\.enc/
          opposing_filename = $1
          action = "Unpacking"
        else
          filename =~ /#{path_to_metadata}\/(.*)/
          opposing_filename = "#{$1}.enc"
          action = "Packing"
        end       

        # Write encrypted/decryption action
        enc_decrypt_result = raw_contents.send(packer_method, @key)
        puts "#{action}\s".informational + filename + "\sto\s".informational + "#{path_to_metadata}/" + opposing_filename
        write_file(opposing_filename, enc_decrypt_result)
      end
      puts "\ndone".informational
    end  
 
    def path_to_metadata
      "bcome/metadata"
    end

    def write_file(filename, contents)
      filepath = "#{path_to_metadata}/#{filename}"
      File.open("#{filepath}", 'w') { |f| f.write(contents) }
    end
 
    def all_unencrypted_filenames
      Dir["#{metadata_path}/*"].reject {|f| f =~ /\.enc/}  
    end

    def all_encrypted_filenames
      Dir["#{metadata_path}/*.enc"]
    end

    def metadata_path
      "bcome/metadata"
    end

  end
end
