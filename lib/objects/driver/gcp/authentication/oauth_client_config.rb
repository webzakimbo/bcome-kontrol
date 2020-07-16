require 'digest/md5'

module Bcome::Driver::Gcp::Authentication
  class OauthClientConfig

    attr_reader :scopes, :secrets_filename

    def initialize(scopes, secrets_filename)
      @scopes = scopes
      @secrets_filename = secrets_filename
    end

    def ==(other)
      checksum == other.checksum
    end

    def checksum
      @checksum ||= ::Digest::MD5.hexdigest(Marshal.dump("#{@scopes}-#{@secrets_filename}"))
    end
 
  end
end
