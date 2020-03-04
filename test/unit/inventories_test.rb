load "#{File.dirname(__FILE__)}/../base.rb"

class InventoriesTest < ActiveSupport::TestCase
  include UnitTestHelper

  def xtest_should_be_able_to_create_a_inventory
    # Given
    estate = given_a_dummy_estate

    views = [
      identifier: "foo",
      description: "bar",
      type: "inventory"
    ]

    # When
    ::Bcome::Node::Factory.send(:new).create_tree(estate, views)
    inventory = estate.resources.first
  
    # Then
    assert inventory.is_a?(::Bcome::Node::Inventory::Defined)
    assert inventory.class.to_s == "inventory"
  end

  def xtest_that_static_inventories_can_have_servers
    # Given
    estate = given_a_dummy_estate

    ips = [
      "111.222.333.444", "999.888.777.666"
    ]  

    identifiers = [
      given_a_random_string_of_length(4), given_a_random_string_of_length(4)
    ]
   
    collection_crumb = given_a_random_string_of_length(3)

    server_data = { 
      "#{estate.namespace}:#{collection_crumb}" => [
         { :identifier => identifiers[0], public_ip_address: ips[0] },
         { :identifier =>  identifiers[1], public_ip_address: ips[1] },
       ]
    }.deep_symbolize_keys

    views = [
      identifier: collection_crumb,
      description: "bar",
      type: "inventory",
      load_machines_from_cache: true
    ]

    # When
    ::Bcome::Node::Factory.send(:new).create_tree(estate, views)
    inventory = estate.resources.first

    inventory.expects(:load_machines_config).returns(server_data).at_least_once
    inventory.load_nodes
 
    # Sanity
    assert inventory.parent == estate
    assert inventory.is_a?(::Bcome::Node::Inventory::Defined)
    assert inventory.resources.size == 2
    
    # And also that
    inventory.resources.each_with_index do |resource, index|
      assert resource.is_a?(::Bcome::Node::Server::Static)
      assert resource.public_ip_address == ips[index]
      assert resource.identifier == identifiers[index]
      assert resource.parent == inventory
    end
  end

  def xtest_should_replace_static_node_if_identifier_defined_both_statically_and_is_returned_dynamically
    # Rationale: Dynamic nodes are always authoritative

    # Given
    estate = given_a_dummy_estate
    duplicate_identifier = given_a_random_string_of_length(5) 

    static_node_ip_address = "static.node.host.name"      

    remote_node = mock("remote node")
    remote_node.expects(:identifier).returns(duplicate_identifier).at_least_once
    remote_node.expects(:dynamic_server?).returns(true)

    collection_crumb = given_a_random_string_of_length(3)
 
    static_server_data = {
      "#{estate.namespace}:#{collection_crumb}" => [
        { :identifier => duplicate_identifier, public_ip_address: static_node_ip_address }
      ]
    }.deep_symbolize_keys

    views = [
      identifier: collection_crumb,
      description: "bar",
      type: "inventory",
      load_machines_from_cache: true
    ]

    ::Bcome::Node::Factory.send(:new).create_tree(estate, views)
    inventory = estate.resources.first
    inventory.expects(:load_machines_config).returns(static_server_data).at_least_once

    inventory.load_nodes

    # Sanity
    assert inventory.resources.size == 1

    static_server = inventory.resources.first
    assert static_server.is_a?(Bcome::Node::Server::Static)

    # When
    inventory.resources << remote_node
  end
end
