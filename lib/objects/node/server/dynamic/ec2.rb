module Bcome::Node::Server::Dynamic 
  class Ec2 < Bcome::Node::Server::Dynamic::Base

    class << self

      def dynamic_server_type
        :ec2
      end

      def new_from_fog_instance(fog_instance, parent)
        identifier = fog_instance.tags['Name']
        identifier = override_identifier(parent, identifier)

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

    def cloud_server        
      views[:ec2_server]
    end

  end
end
