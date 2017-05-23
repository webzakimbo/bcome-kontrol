module Bcome::Node::Inventory
  class Static < ::Bcome::Node::Inventory::Base

    def initialize(params)
      set_static_servers_from_params(params[:view_data])
      super(params)
    end

    def self.to_s
      'static inventory'
    end

    private

    def set_static_servers_from_params(params)
      if server_configs = params[:servers]
        server_configs.each {|server_config|
          resources << ::Bcome::Node::Server::Static.new(view_data: server_config, parent: self)
        }
      end
    end

  end
end
