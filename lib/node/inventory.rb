module Bcome::Node
  class Inventory < ::Bcome::Node::Base

    def self.to_s
      "inventory"
    end

    def list_key
      :server
    end

    def ls
      raw_servers = fetch_server_list      
      raw_servers.each {|raw_server| 
       @resources << ::Bcome::Node::Server.new_from_fog_instance(raw_server, self)
      } 
      super
    end

    def fetch_server_list
      network_driver.fetch_server_list
    end

    def list_attributes
      {
        "identifier": :identifier,
        "internal ip": :internal_interface_address,
        "public ip": :public_ip_address,
      }
    end

  end
end
