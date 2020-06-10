# frozen_string_literal: true

module Bcome
  module Version
    def self.name
      'bcome'
    end

    def self.release
      '2.0.0'
    end

    def self.release_name
      'multicloud & hybrid'
    end

    def self.display
      "#{name} #{release} #{release_name}"
    end
  end
end
