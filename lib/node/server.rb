module Bcome::Node
  class Server < Bcome::Node::Base

    class << self
      def new_from_fog_instance(fog_instance, parent)
      
        identifier = fog_instance.tags["Name"]

        params = {
          identifier: identifier,
          internal_interface_address: fog_instance.private_ip_address,
          public_ip_address: fog_instance.public_ip_address,
          role: fog_instance.tags["function"],
          description: "EC2 server - #{identifier}",
          type: "server"
        }
 
        return new({
          parent: parent,
          view_data: params,
        })      
      end
    end

    def ls
      puts "\n" + visual_hierarchy.orange + "\n"
      puts pretty_description
      puts "\s\s\nHit 'menu' to see your options\n\n".green
    end

    def list_attributes
      ::Bcome::Node::Inventory.list_attributes
    end

  end
end
