class ::Bcome::Orchestrator
  include ::Singleton

  attr_reader :context

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
