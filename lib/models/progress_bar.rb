module Bcome
  class ProgressBar

    include Singleton

    attr_reader :count

    def initialize
      @count = 0
    end

    def increment!
      @count += 1
    end

    def reset!
      @count = 0
    end

    def indicate(config, in_progress)
      prefix = in_progress ? config[:prefix].blinking : config[:prefix]

      bar = prefix + "#{config[:indice] * @count}>".cyan + " (#{@count} #{config[:indice_descriptor]})" + "\r"
      print bar
    end

    def indicate_and_increment!(config, in_progress)
      increment!
      indicate(config, in_progress)
    end

  end
end
