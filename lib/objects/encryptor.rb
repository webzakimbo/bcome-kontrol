# frozen_string_literal: true

require 'diffy'

module Bcome
  class Encryptor
    UNENC_SIGNIFIER = ''
    ENC_SIGNIFIER = 'enc'

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
      nil
    end

    def prompt_for_key
      puts "\n"
      print 'Please enter an encryption key (and if your data is already encrypted, you must provide the same key): '.informational
      @key = STDIN.noecho(&:gets).chomp
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
       diff
#      prompt_for_key
#      toggle_packed_files(all_encrypted_filenames, :decrypt)
#      nil
    end


    ##---

    def decrypt_file_data(filename)
      raw_contents = File.read(filename)
      return raw_contents.send(:decrypt, @key)
    end

    def enc_file_diff(filename)
      # Get decrypted file data
      decrypted_data_for_filename = decrypt_file_data(filename)

      # Get unpacked file data
      opposing_filename = opposing_file_for_filename(filename)
      unpacked_file_data = File.read(opposing_filename)

      # there are no differences
      return nil if decrypted_data_for_filename.eql?(unpacked_file_data)
  
      # return the left and right diffs 
      all_diffs = file_diffs(decrypted_data_for_filename, unpacked_file_data, :left) + file_diffs(decrypted_data_for_filename, unpacked_file_data, :right)
      
      return all_diffs.collect{|line|   
        line =~ /^\+(.+)$/ ? line.bc_green : line.bc_red
      }.join("\n")
    end

    def opposing_file_for_filename(filename)
      filename =~ %r{#{path_to_metadata}/(.+)\.enc}
      return "#{path_to_metadata}/#{Regexp.last_match(1)}" 
    end

    def left_diffs(file_one, file_two)
      file_diffs(file_one, file_two, :left)
    end

    def right_diffs(file_one, file_two)
      file_diffs(file_one, file_two, :right)
    end

    def file_diffs(file_one, file_two, method)
      all_lines = ::Diffy::SplitDiff.new(file_one, file_two).send(method).split("\n")
      diffed_lines = all_lines.select{|line| line =~ /^[+-](.+)$/}
      return diffed_lines
    end

    def diff
      prompt_for_key
      all_encrypted_filenames.each do |filename|
        if diffs = enc_file_diff(filename)
          puts "\n+/- diff\s".warning + filename + "\shas differences that would overwrite changes in your local unpacked version\n\n"
          puts diffs
        end   
      end
    end

    def toggle_packed_files(filenames, packer_method)
      raise 'Missing encryption key. Please set an encryption key' unless @key

      filenames.each do |filename|
        # Get raw
        raw_contents = File.read(filename)

        if packer_method == :decrypt
          filename =~ %r{#{path_to_metadata}/(.+)\.enc}
          opposing_filename = Regexp.last_match(1)
          action = 'Unpacking'
        else
          filename =~ %r{#{path_to_metadata}/(.*)}
          opposing_filename = "#{Regexp.last_match(1)}.enc"
          action = 'Packing'
        end

        # Write encrypted/decryption action
        enc_decrypt_result = raw_contents.send(packer_method, @key)
        puts "#{action}\s".informational + filename + "\sto\s".informational + "#{path_to_metadata}/" + opposing_filename
        write_file(opposing_filename, enc_decrypt_result)
      end
      puts "\ndone".informational
    end

    def path_to_metadata
      'bcome/metadata'
    end

    def write_file(filename, contents)
      filepath = "#{path_to_metadata}/#{filename}"
      File.open(filepath.to_s, 'w') { |f| f.write(contents) }
    end

    def all_unencrypted_filenames
      Dir["#{metadata_path}/*"].reject { |f| f =~ /\.enc/ }
    end

    def all_encrypted_filenames
      Dir["#{metadata_path}/*.enc"]
    end

    def metadata_path
      'bcome/metadata'
    end
  end
end
