
load "#{File.dirname(__FILE__)}/../base.rb"

class WorkspaceTest < ActiveSupport::TestCase
  include UnitTestHelper

  def test_should_initialize_workspace
    # Given/when
    workspace = ::Bcome::Workspace.instance

    # Then
    assert workspace.is_a?(::Bcome::Workspace)

    # And also that
    assert workspace.console_set? == false
    assert workspace.has_context? == false
  end

  def test_should_set_irb_context
    # Given
    workspace = ::Bcome::Workspace.instance
    context_object = given_a_dummy_estate

    workspace.expects(:spawn_into_console_for_context).returns(nil)

    # When
    workspace.set(context: context_object)

    # Then
    assert workspace.has_context? == true
    assert workspace.object_is_current_context?(context_object) == true
  end

  def test_should_correctly_set_irb_prompt
    # Given
    workspace_with_no_context = ::Bcome::Workspace.instance
    default_prompt = 'whatever'
    workspace_with_no_context.expects(:default_prompt).returns(default_prompt)

    # When & Then
    assert workspace_with_no_context.irb_prompt == default_prompt
  end
end
