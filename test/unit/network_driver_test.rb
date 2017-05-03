load "#{File.dirname(__FILE__)}/../base.rb"

class NetworkDriverTest < ActiveSupport::TestCase

  include UnitTestHelper

  def test_should_be_able_to_instantiate_an_ec2_driver
    # Given
    config = {
      type: "ec2",
      credentials_key: "econsultancy",
      provisioning_region: "foo"
    }

    # When
    driver = Bcome::Driver::Base.create_from_config(config)

    # Then
    assert driver.is_a?(Bcome::Driver::Base)
    assert driver.is_a?(Bcome::Driver::Ec2)
    assert driver.credentials_key == credentials_key
    assert driver.provisioning_region == provisioning_region
  end

end
