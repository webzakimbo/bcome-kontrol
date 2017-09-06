module Bcome::Registry::Command
  class Internal < Base

    # In which the bcome context is passed to an external call

    def execute(node, arguments)
      begin
        processed_arguments = process_arguments(arguments)
        orchestrator = orch_klass.new(node, arguments)
        orchestrator.do_execute 
      rescue Interrupt
        puts "\nExiting gracefully from interrupt\n".warning
      end
    end

    def validate(*params)
      super
    end

    def orch_klass
      @orch_klass ||= do_constantize_orch_klass
    end

    def do_constantize_orch_klass
      klass_name = "Bcome::Orchestration::#{@data[:orch_klass]}"
      begin  
        klass_name.constantize
      rescue NameError
        raise ::Bcome::Exception::CannotFindInternalRegistryKlass.new "'#{@data[:console_command]}'. #{klass_name} does not exist. Make sure you've created this class inside your orchestration folder in bcome/orchestration"
      end
    end

    def expected_keys
      super + [:orch_klass]
    end
  end
end
