require 'openssl'

# Adapted from https://stackoverflow.com/questions/39033577/opensslcipherciphererror-wrong-final-block-length

class String

  ALGORITHM = 'AES-256-ECB'

  def encrypt(key)
    begin
      cipher = OpenSSL::Cipher.new(ALGORITHM)
      cipher.encrypt()
      cipher.key = key.as_256_bit_key
      crypt = cipher.update(self) + cipher.final()
      crypt_string = (Base64.encode64(crypt))
      return crypt_string
    rescue Exception => e
      puts "Failed to encrypt: #{e.message}"
    end
  end

  def decrypt(key)
    begin
      cipher = OpenSSL::Cipher.new(ALGORITHM)
      cipher.decrypt()
      cipher.key = key.as_256_bit_key
      tempkey = Base64.decode64(self)
      crypt = cipher.update(tempkey)
      crypt << cipher.final()
      return crypt
    rescue Exception
      raise ::Bcome::Exception::InvalidMetaDataEncryptionKey.new
    end
  end

  def as_256_bit_key
    ::Digest::SHA256.digest self
  end

end
