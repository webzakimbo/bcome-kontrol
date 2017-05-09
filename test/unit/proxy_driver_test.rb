load "#{File.dirname(__FILE__)}/../base.rb"

class ProxyDriverTest < ActiveSupport::TestCase

  include UnitTestHelper

  def test_should_be_able_to_instantiate_one
    # Given
    node = mock("server node")
    bastion_host_user = given_a_random_string_of_length(10)   
 
    config = { :bastion_host_user => bastion_host_user }

    # When
    proxy_data = ::Bcome::Ssh::ProxyData.new(config, node)

    # Then
    assert proxy_data.is_a?(Bcome::Ssh::ProxyData)
    assert bastion_host_user == proxy_data.bastion_host_user
  end

  def test_should_raise_with_missing_host_id_if_none_provided
    # Given
    node = mock("server node")

    config = {
      :host_lookup => "by_inventory_node",
    }
 
    proxy_data = ::Bcome::Ssh::ProxyData.new(config, node)
 
    # When/then
    assert_raise ::Bcome::Exception::InvalidProxyConfig do
      proxy_data.host
    end
  end

  def test_should_raise_with_missing_host_lookup_if_none_provided
    # Given
    node = mock("server node")
    bastion_host_identifier = given_a_random_string_of_length(10)

    config = {
      :host_id => bastion_host_identifier
    }
  
    proxy_data = ::Bcome::Ssh::ProxyData.new(config, node)
 
    # When/then
    assert_raise ::Bcome::Exception::InvalidProxyConfig do
      proxy_data.host
    end
  end

  def test_should_catch_invalid_host_lookup_method_where_incorrect_lookup_method_provided
    # Given
    node = mock("server node")
    bastion_host_identifier = given_a_random_string_of_length(10)

    config = {
      :host_id => bastion_host_identifier,
      :host_lookup => :i_dont_exist
    }
  
    proxy_data = ::Bcome::Ssh::ProxyData.new(config, node)
 
    # When/then
    assert_raise ::Bcome::Exception::InvalidProxyConfig do
      proxy_data.host
    end
  end


  def test_should_get_host_by_inventory_node
    # Given
    node = mock("server node")
    bastion_host_identifier = given_a_random_string_of_length(10)

    mocked_bastion_node = mock("bastion node")
    bastion_node_hostname = given_a_random_string_of_length(10)
    mocked_bastion_node.expects(:public_ip_address).returns(bastion_node_hostname).twice  

    config = {
      :host_id => bastion_host_identifier,
      :host_lookup => :by_inventory_node
    }

    node.expects(:recurse_resource_for_identifier).with(bastion_host_identifier).returns(mocked_bastion_node)

    proxy_data = ::Bcome::Ssh::ProxyData.new(config, node)

    # When
    bastion_node_host = proxy_data.host

    # Then
    # and all our expectations are met

    # and also that
    assert bastion_node_host == bastion_node_hostname
  end

  def test_should_raise_when_failing_to_find_indicated_host_by_inventory_node
    # Given
    node = mock("server node")
    bastion_host_identifier = given_a_random_string_of_length(10)

    config = {
      :host_id => bastion_host_identifier,
      :host_lookup => :by_inventory_node
    }

    node.expects(:recurse_resource_for_identifier).with(bastion_host_identifier).returns(nil)

    proxy_data = ::Bcome::Ssh::ProxyData.new(config, node)

    # When/then
    assert_raise ::Bcome::Exception::CantFindProxyHostByIdentifier do
      proxy_data.host
    end

    # and all our expectations are met
  end

  def test_should_raise_when_bastion_host_found_by_inventory_node_does_not_contain_a_public_ip_address
    # Given
    node = mock("server node")
    bastion_host_identifier = given_a_random_string_of_length(10)

    mocked_bastion_node = mock("bastion node")
    mocked_bastion_node.expects(:public_ip_address).returns(nil)

    config = {
      :host_id => bastion_host_identifier,
      :host_lookup => :by_inventory_node
    }

    node.expects(:recurse_resource_for_identifier).with(bastion_host_identifier).returns(mocked_bastion_node)

    proxy_data = ::Bcome::Ssh::ProxyData.new(config, node)

    # When
    assert_raise ::Bcome::Exception::ProxyHostNodeDoesNotHavePublicIp do
      proxy_data.host
    end  
    # and all our expectations are met
  end

  def test_should_return_config_defined_proxy_hostname
    # Given
    node = mock("server node")
    predefined_hostname = "foo.bar.com"

    config = {
      :host_lookup => :by_host_or_ip,
      :host_id => predefined_hostname
    }

    proxy_data = ::Bcome::Ssh::ProxyData.new(config, node)

    # When
    hostname = proxy_data.host

    # Then
    assert hostname == predefined_hostname
  end

end
