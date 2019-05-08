module Bcome::Driver
  class Gcp < Bcome::Driver::Base

    # TODO - Evaluate the different authentication schemes. For this scratch we'll go Oauth for convenience. 
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    APPLICATION_NAME = 'Bcome GCP lister'.freeze
    CREDENTIALS_PATH = 'client_secrets.json'.freeze
    TOKEN_PATH = 'token.yaml'.freeze

    # Read-only scope for now. We're only interested in listing
    # Full list of scopes: /Users/guillaume/.rvm/gems/ruby-2.3.3@gcp-scratch/gems/google-api-client-0.29.1/generated/google/apis/compute_beta.rb
    # TODO - scope should be user determined, as the gcp driver for any given namespace will be made available for scripting purposes.
    SCOPE = ::Google::Apis::ComputeBeta::AUTH_COMPUTE_READONLY

 
    def initialize(*params)
      super
    end

    def fetch_server_list(filters)
      # TODO - fix hardcoded project & zone: this will come from the networks config 
      project = "webzakimbo-spike" ## TODO use bcome's inheritance model
      zone = "europe-west2-c" ## TODO "
      instances = gcp_client.list_instances(project, zone)
      instances.items
    end

    def set_gcp_client
      client = ::Google::Apis::ComputeBeta::ComputeService.new
      client.client_options.application_name = APPLICATION_NAME
      client.authorization = authorize  ## TODO - currently will break flow when Oauth triggered
      client
    end   
 
    def gcp_client
      @gcp_client ||= set_gcp_client
    end  

    protected

    ##
    # Ensure valid credentials, either by restoring from the saved credentials
    # files or intitiating an OAuth2 authorization. If authorization is required,
    # the user's default browser will be launched to approve the request.
    #
    # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
    def authorize
      client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: OOB_URI)
        puts "Open the following URL in the browser and enter the resulting code after authorization:\n" + url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI
        )
      end
      credentials
    end





  end
end
