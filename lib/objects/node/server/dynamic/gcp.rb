module Bcome::Node::Server::Dynamic 
  class Gcp < Bcome::Node::Server::Dynamic::Base

    class << self

      def dynamic_server_type
        :gcp
      end

      def new_from_gcp_instance(gcp_instance, parent)
        identifier = gcp_instance.name 
        identifier = override_identifier(parent, identifier)
   
        params = {
          identifier: identifier,
          internal_ip_address: gcp_instance.network_interfaces.first.network_ip,
          public_ip_address: gcp_instance.network_interfaces.first.access_configs.first.nat_ip, # TODO 1. never really solved presentation of multiple network interfaces, 2. nat_ip? 
          role: "role TODO",                                                ## ^^ bcome should have them all, but choose (or to be configurable) as to what to present/default to 
          gcp_server: gcp_instance  # TODO override         
        }

        new(parent: parent, views: params)
      end
    end

    def cloud_server       
      views[:gcp_server]
    end

  end
end
