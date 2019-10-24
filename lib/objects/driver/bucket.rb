# frozen_string_literal: true

module Bcome::Driver
  class Bucket
    include Singleton

    def initialize
      @drivers = []
    end

    def driver_for_network_data(network_data, node)
      found_driver = @drivers.select { |driver| driver.config == network_data }.first
      found_driver || create_network_driver(network_data, node)
    end

    def create_network_driver(network_data, node)
      driver = ::Bcome::Driver::Base.create_from_config(network_data, node)
      @drivers << driver
      driver
    end
  end
end
