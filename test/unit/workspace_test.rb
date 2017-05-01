load "#{File.dirname(__FILE__)}/../base.rb"

class WorkspaceTest < ActiveSupport::TestCase
 
  def test_should_initialize_workspace
    # Given/when
    workspace = ::Bcome::Workspace.instance

    # Then
    assert workspace.is_a?(::Bcome::Workspace)

    # And also that
    assert workspace.console_set? == false
    assert workspace.has_context? == false
  end

  def Xtest_should_set_irb_context
    # Given
    workspace = ::Bcome::Workspace.new

    context_object = Object.new
    context_object.expects(:irb_workspace=).with(workspace)
  
    # When
    workspace.set({
      :context => context_object
    })

    # Then
    assert workspace.has_context? == true
    assert workspace.object_is_current_context?(context_object) == true    
  end

  def Xtest_should_correctly_set_irb_prompt
    # Given
    workspace_with_no_context = ::Bcome::Workspace.new
    default_prompt = "whatever"
    workspace_with_no_context.expects(:default_prompt).returns(default_prompt)  

    # When & Then
    assert workspace_with_no_context.irb_prompt == default_prompt
  end

end
