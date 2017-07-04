module Bcome::Context
  def is_current_context?
    ::Bcome::Workspace.instance.object_is_current_context?(self)
  end

  def irb_workspace=(workspace)
    @irb_workspace = workspace
  end

  def previous_irb_workspace=(workspace)
    @previous_workspace = workspace
  end
end
