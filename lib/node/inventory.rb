module Bcome::Node
  class Inventory < ::Bcome::Node::Base

    def self.to_s
      "inventory"
    end

    def list_key
      :server
    end

  end
end
