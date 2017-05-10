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

    def indicate(bar_prefix, bar_indice, indice_descriptor)
      bar = "#{bar_prefix}" + "#{bar_indice * @count}>".cyan + " (#{@count} #{indice_descriptor})" + "\r"
      print bar
    end

    def indicate_and_increment!(bar_prefix, bar_indice, indice_descriptor)
      increment!
      indicate(bar_prefix, bar_indice, indice_descriptor)
    end

  end
end
