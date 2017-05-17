load "#{File.dirname(__FILE__)}/../base.rb"

class NetworkDriverTest < ActiveSupport::TestCase
  include UnitTestHelper

  def test_should_be_able_to_instantiate_an_ec2_driver
    # Given
    credentials_key = 'webzakimbo'
    provisioning_region = 'whatever'
    config = {
      type: 'ec2',
      credentials_key: credentials_key,
      provisioning_region: provisioning_region
    }

    # When
    driver = Bcome::Driver::Base.create_from_config(config)

    # Then
    assert driver.is_a?(Bcome::Driver::Base)
    assert driver.is_a?(Bcome::Driver::Ec2)
    assert driver.credentials_key == credentials_key
    assert driver.provisioning_region == provisioning_region
  end

  def test_should_raise_if_invalid_driver_type
    # Given
    Bcome::Driver::Base.expects(:klass_for_type).returns(foo: :bar)
    non_existent_driver = :i_dont_exist

    # when/then
    assert_raise Bcome::Exception::InvalidNetworkDriverType do
      Bcome::Driver::Base.create_from_config(type: non_existent_driver)
    end
  end

  def test_ec2_driver_get_fog_client_wiring
    # Given
    mocked_ec2_provider = mock('Ec2 provider')

    credentials_key = 'webzakimbo'
    provisioning_region = 'whatever'
    config = {
      type: 'ec2',
      credentials_key: credentials_key,
      provisioning_region: provisioning_region
    }

    driver = Bcome::Driver::Base.create_from_config(config)

    ::Fog.expects(:credential=).with(credentials_key)
    ::Fog::Compute.expects(:new).with(provider: 'AWS', region: provisioning_region).returns(mocked_ec2_provider)

    # When
    assert driver.fog_client == mocked_ec2_provider

    # and also that all our expectations are met
  end

  def test_ec2_driver_filters_wiring
    # Given
    mocked_ec2_provider = mock('Ec2 provider')

    credentials_key = 'webzakimbo'
    provisioning_region = 'whatever'
    config = {
      type: 'ec2',
      credentials_key: credentials_key,
      provisioning_region: provisioning_region
    }

    driver = Bcome::Driver::Base.create_from_config(config)

    ::Fog.expects(:credential=).with(credentials_key)
    ::Fog::Compute.expects(:new).with(provider: 'AWS', region: provisioning_region).returns(mocked_ec2_provider)

    filters = { foo: :bar }

    mocked_all_servers = mock('All ec2 servers')
    unfiltered_server_result = mock("full server result")
    mocked_all_servers.expects(:all).returns(mocked_all_servers)


    mocked_filtered_servers = mock('Filtered servers')
    mocked_all_servers.expects(:all).with(filters).returns(mocked_filtered_servers)
    mocked_ec2_provider.expects(:servers).returns(mocked_all_servers)

    # When
    servers = driver.fetch_server_list(filters)

    # Then
    assert servers == mocked_filtered_servers

    # And also that all our expectations are met.
  end

  def test_should_be_able_to_instantiate_a_static_driver
    # Given
    config = {
      type: 'static'
    }

    # When
    driver = Bcome::Driver::Base.create_from_config(config)

    # Then
    assert driver.is_a?(Bcome::Driver::Base)
    assert driver.is_a?(Bcome::Driver::Static)
  end
end
