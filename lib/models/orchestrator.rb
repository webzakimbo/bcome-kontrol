class ::Bcome::Orchestrator
  include ::Singleton

  attr_reader :context

  def initialize
    @silence = false
  end

  def silence_command_output!
    @silence = true
  end

  def command_output_silenced?
    @silence == true
  end

  def get(breadcrumb = nil)
    ::Bcome::Bootup.orchestrate(breadcrumb)
    return @context
  end

  def set(params)
    @context = params[:context]
    @context.load_nodes if context.is_a?(::Bcome::Node::Inventory) && !context.nodes_loaded?
    return
  end
 
end
