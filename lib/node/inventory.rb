module Bcome::Node
  class Inventory < ::Bcome::Node::Base

    class << self
      def to_s
        "inventory"
      end

      def list_attributes
        {
         "identifier": :identifier,
         "internal ip": :internal_interface_address,
         "public ip": :public_ip_address,
        }
      end
    end
 
    def list_key
      :server
    end

    def ls
      set_resources unless @resources.any?
      super
    end

    def reload!
      puts "\nReloading inventory...\n".green
      set_resources
      puts "\nDone. Hit 'ls' to see the refreshed inventory.\n".green
    end

    def override_server_identifier?
      !@override_identifier.nil?
    end

    def set_resources
      @resources = []
      raw_servers = fetch_server_list
      raw_servers.each {|raw_server|
       @resources << ::Bcome::Node::Server.new_from_fog_instance(raw_server, self)
      }
    end

    def fetch_server_list
      network_driver.fetch_server_list
    end

    def list_attributes
      ::Bcome::Node::Inventory.list_attributes
    end

  end
end
