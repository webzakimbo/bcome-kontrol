load "#{File.dirname(__FILE__)}/../base.rb"

class NetworkDriverTest < ActiveSupport::TestCase

  include UnitTestHelper

  def test_should_be_able_to_instantiate_a_proxyless_ssh_driver
    # Given
    ssh_user = "ubuntu"
    node = mock("server Node")
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
    node = mock("server node")
    driver = Bcome::Ssh::Driver.new(config, node)

    system_user = given_a_random_string_of_length(5)
    ::Bcome::System::Local.instance.expects(:local_user).returns(system_user)

    # Then
    assert driver.user == system_user
  end

  def test_driver_should_create_proxy_when_proxy_config_provided
    # Given
    bastion_host_user = given_a_random_string_of_length(5)
    bastion_host = given_a_random_string_of_length(5)
    node_user = given_a_random_string_of_length(5)
    node_hostname = given_a_random_string_of_length(5)

    config = {
      :proxy => {}
    }

    node = mock("server node")
    node.expects(:internal_interface_address).returns(node_hostname)

    mocked_proxy_data = mock("proxy data")
    mocked_proxy_data.expects(:bastion_host_user).returns(bastion_host_user).times(4)
    mocked_proxy_data.expects(:host).returns(bastion_host).times(2)

    ::Bcome::Ssh::ProxyData.expects(:new).with(config[:proxy], node).returns(mocked_proxy_data)
    
    mocked_proxy = mock("proxy")
    proxy_connection_string = "#{Bcome::Ssh::Driver::PROXY_CONNECT_PREFIX} #{bastion_host_user}@#{bastion_host}"
    ::Net::SSH::Proxy::Command.expects(:new).with(proxy_connection_string).returns(mocked_proxy)
       
    # when
    driver = Bcome::Ssh::Driver.new(config, node)
    driver.expects(:fallback_local_user).returns(node_user)

    returned_proxy = driver.proxy

    # then
    assert returned_proxy == mocked_proxy

    ssh_connection_string = "#{Bcome::Ssh::Driver::PROXY_SSH_PREFIX} #{bastion_host_user}@#{bastion_host}\" #{node_user}@#{node_hostname}"
    node.expects(:execute_local).with(ssh_connection_string).returns(true)
 
    # When/then
    driver.do_ssh

    # and that all our assertions are met
  end

end
