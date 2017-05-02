module Bcome::Node
  class Estate < Bcome::Node::Base

    def self.to_s
      'estate'
    end

    def prompt_breadcrumb
      @identifier
    end

  end
end
