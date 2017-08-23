module Bcome::Node::Server
  class Static < Bcome::Node::Server::Base
    def self.to_s
      'static server'
    end

    def initialize(params)
      config = params[:views]
      @identifier = config[:identifier]
      @public_ip_address = config[:public_ip_address]
      @internal_ip_address = config[:internal_ip_address]
      @cloud_tags = config[:cloud_tags]
      verify_we_have_at_least_one_interface(config)
      super
    end

    attr_reader :cloud_tags

    def verify_we_have_at_least_one_interface(config)
      raise Bcome::Exception::MissingIpaddressOnServer, config unless has_at_least_one_interface?
    end

    def has_at_least_one_interface?
      @public_ip_address || @internal_ip_address
    end

    def static_server?
      true
    end
  end
end
