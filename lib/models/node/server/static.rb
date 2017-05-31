module Bcome::Node::Server
  class Static < Bcome::Node::Server::Base

    def initialize(params)
      config = params[:views]
      @identifier = config[:identifier]
      @public_ip_address = config[:public_ip_address]
      @internal_ip_address = config[:internal_ip_address]
      verify_we_have_at_least_one_interface(config)
      super
    end

    def verify_we_have_at_least_one_interface(config)
      raise ::Bcome::Exception::MissingIpaddressOnServer.new(config) unless has_at_least_one_interface?
    end

    def has_at_least_one_interface?
      @public_ip_address || @internal_ip_address
    end

    def static_server?
      true
    end 

  end
end
