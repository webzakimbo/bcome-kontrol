module Bcome::Context

  def is_current_context?
    ::BCOME.object_is_current_context?(self)
  end

  def irb_workspace=(workspace)
    @irb_workspace = workspace 
  end

  def previous_irb_workspace=(workspace)
    @previous_workspace = workspace
  end
end
