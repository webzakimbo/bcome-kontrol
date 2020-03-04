# frozen_string_literal: true

class ::Bcome::Orchestrator
  include ::Singleton

  attr_reader :context

  def initialize
    reset!
  end

  def reset!
    @silence = false
    @tail_command_output = false
    @multi_node = false
  end

  def is_multi_node?
    @multi_node == true
  end

  def silence_command_output!
    @silence = true
  end

  def command_output_silenced?
    @silence == true
  end

  def tail_all_command_output!(node)
    @multi_node = (node.machines.size > 1) ? true : false
    @tail_command_output = true
  end

  def tail_all_command_output?
    @tail_command_output == true
  end

  def get(breadcrumb = nil)
    context = ::Bcome::Bootup.traverse(breadcrumb)
    raise Bcome::Exception::NoNodeFoundForBreadcrumb, breadcrumb unless context

    context.load_nodes if context.inventory? && !context.nodes_loaded?
    context
  end
end
