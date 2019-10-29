# frozen_string_literal: true

module Bcome
  module Version
    def self.release
      "2.0.0"
    end 

    def self.name
      "multicloud"
    end

    def self.display
      "bcome #{release} #{name}"
    end
  end
end
