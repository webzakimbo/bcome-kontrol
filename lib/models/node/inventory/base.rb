module Bcome::Node::Inventory
  class Base < ::Bcome::Node::Base

    def list_key
      :server
    end

    def machines
      @resources.active
    end

  end
end
