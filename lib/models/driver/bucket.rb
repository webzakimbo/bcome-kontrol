module Bcome::Driver
  class Bucket
    include Singleton

    def initialize
      @drivers = []
    end

    def driver_for_network_data(network_data)
      found_driver = @drivers.select{|driver| driver.config == network_data }.first
      found_driver ? found_driver : create_network_driver(network_data)
    end

    def create_network_driver(network_data)
      driver = ::Bcome::Driver::Base.create_from_config(network_data)
      @drivers << driver
      driver
    end

  end
end
