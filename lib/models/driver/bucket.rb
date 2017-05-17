module Bcome::Driver
  class Bucket
    include Singleton

    def initialize
      @drivers = []
    end

    def driver_for_network_data(network_data)
      if driver = @drivers.select{|driver| driver.config == network_data }.first
        driver
      else
        create_network_driver(network_data)
      end
    end

    def create_network_driver(network_data)
      driver = ::Bcome::Driver::Base.create_from_config(network_data)
      @drivers << driver
      driver
    end

  end
end
