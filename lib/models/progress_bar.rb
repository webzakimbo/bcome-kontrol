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
      prefix = in_progress ? config[:prefix].bc_green.blinking : config[:prefix].bc_green
      bar = prefix + "#{config[:indice] * @count}>".bc_cyan + " (#{@count} #{config[:indice_descriptor]})".bc_green + "\r"
      print bar
    end

    def indicate_and_increment!(config, in_progress)
      increment!
      indicate(config, in_progress)
    end

  end
end
