module ::Bcome::Ssh
  class Command

    attr_reader :raw, :stdout, :stderr, :exit_code, :exit_signal, :node, :bootstrap, :success_codes

    def initialize(params)
      @raw = params[:raw]
      @node = params[:node]
      @exit_code = nil
      @exit_signal = nil
      @stdin = "" ; @stdout = ""; @stderr = ""
    end

    def pretty_result
     return is_success? ? "success".bc_green : "failure".bc_red
    end

    def bootstrap=(bootstrap_value)
      @bootstrap = bootstrap_value
    end

    def output
     command_output = is_success? ? @stdout : "Exit code: #{@exit_code}\n\nSTDERR: #{@stderr}"
     return "\n#{command_output}"
    end

    def is_success?
      exit_code.to_i == 0
    end

    def success_codes
      return @success_codes ? @success_codes : ["0"]
    end

    def stdout=(data)
      @stdout = data
    end

    def stderr=(data)
      @stderr = data
    end

    def exit_code=(data)
      @exit_code = data
    end

    def exit_signal(data)
      @exit_signal = data
    end

  end
end
