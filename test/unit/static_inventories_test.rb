load "#{File.dirname(__FILE__)}/../base.rb"

class StaticInventoriesTest < ActiveSupport::TestCase
  include UnitTestHelper

  def test_should_be_able_to_create_a_static_inventory
    # Given
    estate = given_a_dummy_estate

    view_data = [
      {
        identifier: "foo", 
        description: "bar",
        type: "static_inventory"
      }
    ]

    # When
    ::Bcome::Node::Factory.create_tree(estate, view_data)
    inventory = estate.resources.first
  
    # Then
    assert inventory.is_a?(::Bcome::Node::Inventory::Static)
    assert inventory.class.to_s == "static inventory"
  end

  def test_that_static_inventories_can_have_servers
    # Given
    estate = given_a_dummy_estate

    public_ip_address_server_1 = "111.222.333.444"
    public_ip_address_server_2 = "999.888.777.666"

    server_data = [
      { identifier: given_a_random_string_of_length(4), public_ip_address: public_ip_address_server_1 },
      { identifier: given_a_random_string_of_length(4), public_ip_address: public_ip_address_server_2 }
    ]

    view_data = [
      identifier: "foo",
      description: "bar",
      type: "static_inventory",
      servers: server_data
    ]

    # When
    ::Bcome::Node::Factory.create_tree(estate, view_data)
    inventory = estate.resources.first
 
    # Sanity
    assert inventory.parent == estate
    assert inventory.is_a?(::Bcome::Node::Inventory::Static)
    assert inventory.resources.size == 2
    
    # And also that
    inventory.resources.each_with_index do |resource, index|
      assert resource.is_a?(::Bcome::Node::Server::Static)
      assert resource.public_ip_address == server_data[index][:public_ip_address]
      assert resource.identifier == server_data[index][:identifier] 
      assert resource.parent == inventory
    end
  end

end
