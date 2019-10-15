load "#{File.dirname(__FILE__)}/../base.rb"

class NetworkDriverTest < ActiveSupport::TestCase
  include UnitTestHelper

  def test_should_be_able_to_instantiate_a_proxyless_ssh_driver
    # Given
    ssh_user = 'ubuntu'
    node = mock('server Node')
    config = {
      user: ssh_user
    }

    # When
    driver = Bcome::Ssh::Driver.new(config, node)

    # Then
    assert driver.is_a?(Bcome::Ssh::Driver)
    assert driver.has_proxy? == false
    assert driver.user == ssh_user
  end

  def test_proxyless_ssh_driver_should_default_to_local_user_when_non_provided
    # Given
    config = {}
    node = mock('server node')
    driver = Bcome::Ssh::Driver.new(config, node)

    system_user = given_a_random_string_of_length(5)
    ::Bcome::System::Local.instance.expects(:local_user).returns(system_user)

    # Then
    assert driver.user == system_user
  end

end
