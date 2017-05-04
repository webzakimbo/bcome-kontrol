load "#{File.dirname(__FILE__)}/../base.rb"

class SystemTest < ActiveSupport::TestCase
  
  include UnitTestHelper

  ## TODO: SYSTEM: knowns things like my local user, my path?
 
  def test_should_be_able_to_execute_a_local_system_command
    # Given
    command = given_a_random_string_of_length(10)
    mocked_command_result = mock("Mocked command result")

    Object.expects(:system).with(command).returns(mocked_command_result)

    # When
    command_result = ::Bcome::System.instance.run_local(command)

    # Then
    # All our expectations are met

    # And also
    assert command_result == mocked_command_result
  end
end
