# frozen_string_literal: true

module Bcome::Node::Server
  class Static < Bcome::Node::Server::Base
    def host
      'static'
    end

    def initialize(params)
      @view_config = params[:views]

      set_cloud_tags

      @identifier = @view_config[:identifier]
      @public_ip_address = @view_config[:public_ip_address]
      @internal_ip_address = @view_config[:internal_ip_address]
      @cloud_tags = @view_config[:cloud_tags]
      @description = @view_config[:description]
      verify_we_have_at_least_one_interface
      verify_identifier_and_description
      super
    end

    attr_reader :cloud_tags

    attr_reader :public_ip_address

    attr_reader :internal_ip_address

    attr_reader :cloud_tags

    attr_reader :description

    def set_cloud_tags
      @view_config[:cloud_tags] = ::Bcome::Node::Meta::Cloud.new(@view_config[:cloud_tags]) unless @view_config[:cloud_tags].is_a?(::Bcome::Node::Meta::Cloud)
    end

    def verify_we_have_at_least_one_interface
      raise Bcome::Exception::MissingIpaddressOnServer, @view_config unless has_at_least_one_interface?
    end

    def verify_identifier_and_description
      raise Bcome::Exception::Generic, "Your static server defined by #{@view_config} is missing a description" unless @description
      raise Bcome::Exception::Generic, "Your static server defined by #{@view_config} is missing an identifier" unless @identifier
    end

    def has_at_least_one_interface?
      @public_ip_address || @internal_ip_address
    end

    def static_server?
      true
    end
  end
end
