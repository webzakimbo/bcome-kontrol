module Bcome::Node::Server
  class Dynamic < Bcome::Node::Server::Base
    class << self

      def new_from_fog_instance(fog_instance, parent)
        identifier = fog_instance.tags['Name']

        if parent.override_server_identifier?
          identifier =~ /#{parent.override_identifier}/
          identifier = Regexp.last_match(1) if Regexp.last_match(1)
        end

        params = {
          identifier: identifier,
          internal_interface_address: fog_instance.private_ip_address,
          public_ip_address: fog_instance.public_ip_address,
          role: fog_instance.tags['function'],
          description: "EC2 server - #{identifier}",
          ec2_server: fog_instance
        }

        new(parent: parent,
            views: params)
      end
    end

  end
end
