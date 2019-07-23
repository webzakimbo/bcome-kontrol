# frozen_string_literal: true

module Bcome::Node::Server::Dynamic
  class Gcp < Bcome::Node::Server::Dynamic::Base
    class << self
      def dynamic_server_type
        :gcp
      end

      def new_from_gcp_instance(gcp_instance, parent)
        identifier = gcp_instance.name
        identifier = override_identifier(parent, identifier)

        # TODO - Allow for selection (at any namespace level incl. machine) the network interface to use
        # TODO - ditto the access config to use

        ## Hack until we can figure out what's happening with network interfaces
        first_interface = gcp_instance.network_interfaces.first
        network_ip = first_interface.network_ip
        
        # Second hack until can figure out what's going on with access configs
        first_access_config = first_interface.access_configs ? first_interface.access_configs.first : nil
        nat_ip = first_access_config ? first_access_config.nat_ip : nil

        params = {
          identifier: identifier,
          internal_ip_address: network_ip,
          public_ip_address: nat_ip, 
          role: 'role TODO', ## ^^ bcome should have them all, but choose (or to be configurable) as to what to present/default to
          gcp_server: gcp_instance # TODO: override
        }

        new(parent: parent, views: params)
      end
    end

    def do_generate_cloud_tags
      raw_labels = cloud_server.labels ? cloud_server.labels.deep_symbolize_keys : {}
      puts raw_labels.inspect

      ::Bcome::Node::Meta::Cloud.new(raw_labels) 
    end

    def cloud_server
      views[:gcp_server]
    end
  end
end
