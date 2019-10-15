# frozen_string_literal: true

module Bcome::Node::Server::Dynamic
  class Base < Bcome::Node::Server::Base
    class << self
      def to_s
        "#{dynamic_server_type} dynamic server"
      end

      def dynamic_server_type
        raise 'Should be overidden'
      end

      def override_identifier(parent, identifier)
        if parent.override_server_identifier?
          identifier =~ /#{parent.override_identifier}/
          identifier = Regexp.last_match(1) if Regexp.last_match(1)
        end
        identifier
      end
    end

    def do_generate_cloud_tags 
      raise "Should be overidden"
    end

    def cloud_server
      raise 'Should be overidden'
    end
  end
end
