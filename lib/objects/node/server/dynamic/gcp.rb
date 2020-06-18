# frozen_string_literal: true

module Bcome::Node::Server::Dynamic
  class Gcp < Bcome::Node::Server::Dynamic::Base
    class << self
      def dynamic_server_type
        :gcp
      end

      def new_from_gcp_instance(gcp_instance, parent)
        identifier = gcp_instance.name

        ## For now we support only the first network interface
        first_interface = gcp_instance.network_interfaces.first
        network_ip = first_interface.network_ip

        ## And we get the first access config (terraform uses the same pattern for accessing GCP machines also)
        first_access_config = first_interface.access_configs ? first_interface.access_configs.first : nil
        nat_ip = first_access_config ? first_access_config.nat_ip : nil

        params = {
          identifier: identifier,
          description: "GCP server - #{identifier}",
          internal_ip_address: network_ip,
          public_ip_address: nat_ip,
          gcp_server: gcp_instance
        }

        new(parent: parent, views: params)
      end
    end

    def host
      'GCP'
    end

    def do_generate_cloud_tags
      raw_labels = cloud_server.labels ? cloud_server.labels.deep_symbolize_keys : {}
      ::Bcome::Node::Meta::Cloud.new(raw_labels)
    end

    def cloud_server
      views[:gcp_server]
    end
  end
end
