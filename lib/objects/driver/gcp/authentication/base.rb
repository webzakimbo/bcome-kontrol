# frozen_string_literal: true

module Bcome::Driver::Gcp::Authentication
  class Base
    include ::Bcome::LoadingBar::Handler

    ## Overrides
    def authorized?
      raise 'Should be overidden'
    end

    ## Loading bar -

    def loader_title
      'Authenticating' + "\s#{@driver.pretty_provider_name.bc_blue.bold}\s#{@driver.pretty_resource_location.underline}".bc_green
    end

    ## Credential helpers --

    def credential_directory
      '.gauth'
    end

    def full_path_to_credential_file
      "#{credential_directory}/#{credential_file}"
    end

    def credential_file
      "#{@node.keyed_namespace}:#{credential_file_suffix}"
    end

    def ensure_credential_directory
      `mkdir -p #{credential_directory}`
    end
  end
end
