load "#{File.dirname(__FILE__)}/../base.rb"

class InventoriesTest < ActiveSupport::TestCase
  include UnitTestHelper

  def test_should_be_able_to_create_a_inventory
    # Given
    estate = given_a_dummy_estate

    view_data = [
      {
        identifier: "foo", 
        description: "bar",
        type: "inventory"
      }
    ]

    # When
    ::Bcome::Node::Factory.create_tree(estate, view_data)
    inventory = estate.resources.first
  
    # Then
    assert inventory.is_a?(::Bcome::Node::Inventory)
    assert inventory.class.to_s == "inventory"
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
      type: "inventory",
      static_servers: server_data
    ]

    # When
    ::Bcome::Node::Factory.create_tree(estate, view_data)
    inventory = estate.resources.first
 
    # Sanity
    assert inventory.parent == estate
    assert inventory.is_a?(::Bcome::Node::Inventory)
    assert inventory.resources.size == 2
    
    # And also that
    inventory.resources.each_with_index do |resource, index|
      assert resource.is_a?(::Bcome::Node::Server::Static)
      assert resource.public_ip_address == server_data[index][:public_ip_address]
      assert resource.identifier == server_data[index][:identifier] 
      assert resource.parent == inventory
    end
  end

  def test_should_replace_static_node_if_identifier_defined_both_statically_and_is_returned_dynamically
    # Rationale: Dynamic nodes are always authoritative

    # Given
    estate = given_a_dummy_estate
    duplicate_identifier = given_a_random_string_of_length(5) 

    static_node_ip_address = "static.node.host.name"      

    remote_node = mock("remote node")
    remote_node.expects(:identifier).returns(duplicate_identifier).at_least_once
    remote_node.expects(:dynamic_server?).returns(true)
 
    static_server_data = [
      {
        identifier: duplicate_identifier,
        public_ip_address: static_node_ip_address
      }
    ]

    view_data = [
      identifier: "foo",
      description: "bar",
      type: "inventory",
      static_servers: static_server_data
    ]

    ::Bcome::Node::Factory.create_tree(estate, view_data)
    inventory = estate.resources.first

    # Sanity
    assert inventory.resources.size == 1
    static_server = inventory.resources.first
    assert static_server.is_a?(Bcome::Node::Server::Static)

    # When
    inventory.resources << remote_node


  end


end
