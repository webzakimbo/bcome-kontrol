module Bcome::Node::Server  # TODO - ABSTRACT INTO EC2 AND GCP DERIVED TYPES
  class Dynamic < Bcome::Node::Server::Base
    class << self
      def to_s
        'dynamic server'
      end

      def new_from_gcp_instance(gcp_instance, parent)
        identifier = "TODO"
 
        # TODO Consolidate with fog method
        if parent.override_server_identifier?
          identifier =~ /#{parent.override_identifier}/
          identifier = Regexp.last_match(1) if Regexp.last_match(1)
        end
   
        params = {
          identifier: gcp_instance.name,
          internal_ip_address: gcp_instance.network_interfaces.first.network_ip,
          public_ip_address: gcp_instance.network_interfaces.first.access_configs.first.nat_ip, # TODO 1. never really solved presentation of multiple network interfaces, 2. nat_ip? 
          role: "role TODO",                                                ## ^^ bcome should have them all, but choose (or to be configurable) as to what to present/default to 
          gcp_server: gcp_instance  # TODO override         
        }

        new(parent: parent, views: params)
      end

      def new_from_fog_instance(fog_instance, parent)
        identifier = fog_instance.tags['Name']

        if parent.override_server_identifier?
          identifier =~ /#{parent.override_identifier}/
          identifier = Regexp.last_match(1) if Regexp.last_match(1)
        end

        params = {
          identifier: identifier,
          internal_ip_address: fog_instance.private_ip_address,
          public_ip_address: fog_instance.public_ip_address,
          role: fog_instance.tags['function'],
          description: "EC2 server - #{identifier}",
          ec2_server: fog_instance
        }

        new(parent: parent, views: params)
      end
    end

    def do_generate_cloud_tags
      raw_tags = ec2_server ? ec2_server.tags.deep_symbolize_keys : {}
      ::Bcome::Node::Meta::Cloud.new(raw_tags)
    end

    def ec2_server
      views[:ec2_server]
    end
  end
end
