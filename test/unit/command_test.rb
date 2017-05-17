load "#{File.dirname(__FILE__)}/../base.rb"

class CommandTest < ActiveSupport::TestCase
  include UnitTestHelper


  def test_should_be_able_to_create_one
    # Given
    raw_command = given_a_random_string_of_length(10)
    node = mock("Mocked resource")

    # When
    command = ::Bcome::Ssh::Command.new(node: node, raw: raw_command)

    # Then
    assert command.is_a?(Bcome::Ssh::Command)

    # When/then
    command.exit_code = 1
    assert !command.is_success?


    # When/Then
    command.exit_code = 0
    assert command.is_success?
  end

end
