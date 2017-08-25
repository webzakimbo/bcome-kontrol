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
    context = ::Bcome::Bootup.traverse(breadcrumb)
    context.load_nodes if context.is_a?(::Bcome::Node::Inventory) && !context.nodes_loaded?
    context
  end
end
