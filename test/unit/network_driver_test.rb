load "#{File.dirname(__FILE__)}/../base.rb"

class NetworkDriverTest < ActiveSupport::TestCase
  include UnitTestHelper

  def test_should_be_able_to_instantiate_an_ec2_driver
    # Given
    mocked_node = mock("Bcome node")
    credentials_key = 'webzakimbo'
    provisioning_region = 'whatever'
    config = {
      type: 'ec2',
      credentials_key: credentials_key,
      provisioning_region: provisioning_region
    }

    # When
    driver = Bcome::Driver::Base.create_from_config(config, mocked_node)

    # Then
    assert driver.is_a?(Bcome::Driver::Base)
    assert driver.is_a?(Bcome::Driver::Ec2)
    assert driver.credentials_key == credentials_key
    assert driver.provisioning_region == provisioning_region
  end

  def test_should_raise_if_ec2_driver_data_missing_provisioning_region
    # Given
    mocked_node = mock("Bcome node")
    credentials_key = 'webzakimbo'
    provisioning_region = nil
    config = {
      type: 'ec2',
      credentials_key: credentials_key,
      provisioning_region: provisioning_region
    }

    # When/then
    assert_raise Bcome::Exception::Ec2DriverMissingProvisioningRegion do
      ::Bcome::Driver::Base.create_from_config(config, mocked_node)
    end
  end
 
  def test_should_raise_if_invalid_driver_type
    # Given
    mocked_node = mock("Bcome node")
    Bcome::Driver::Base.expects(:klass_for_type).returns(foo: :bar)
    non_existent_driver = :i_dont_exist

    # when/then
    assert_raise Bcome::Exception::InvalidNetworkDriverType do
      Bcome::Driver::Base.create_from_config({type: non_existent_driver}, mocked_node)
    end
  end

  def test_ec2_driver_get_fog_client_wiring
    # Given
    mocked_node = mock("Bcome node")
    mocked_ec2_provider = mock('Ec2 provider')

    credentials_key = 'webzakimbo'
    provisioning_region = 'whatever'
    config = {
      type: 'ec2',
      credentials_key: credentials_key,
      provisioning_region: provisioning_region
    }

    driver = Bcome::Driver::Base.create_from_config(config, mocked_node)

    ::Fog.expects(:credential=).with(credentials_key)
    ::Fog::Compute.expects(:new).with(provider: 'AWS', region: provisioning_region).returns(mocked_ec2_provider)

    # When
    assert driver.fog_client == mocked_ec2_provider

    # and also that all our expectations are met
  end
end
