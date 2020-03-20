# frozen_string_literal: true

module Bcome
  module Version
    def self.name
      'bcome'
    end

    def self.release
      '1.4.0'
    end

    def self.release_name
      'multicloud'
    end

    def self.display
      "#{name} #{release} #{release_name}"
    end
  end
end
