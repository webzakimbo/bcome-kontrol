# frozen_string_literal: true

module ::Bcome::Ssh
  class Command
    attr_reader :raw, :stdout, :stderr, :exit_code, :node

    def initialize(params)
      @raw = params[:raw]
      @node = params[:node]
      @exit_code = nil
      @exit_signal = nil
      @stdin = ''; @stdout = ''; @stderr = ''
    end

    def unset_node
      @node = nil
    end

    def output
      cmd_output = @stdout

      cmd_output += "\nExit code:" + "\s#{@exit_code}"

      if exit_code == 1 && !@stderr.empty?
        cmd_output += "\nSTDERR: #{@stderr}"
      end

      "\n#{cmd_output}"
    end

    def is_success?
      exit_code.to_i == 0
    end

    def success_codes
      ['0']
    end

    attr_writer :stdout

    attr_writer :stderr

    attr_writer :exit_code

    def exit_signal(data)
      @exit_signal = data
    end
  end
end
