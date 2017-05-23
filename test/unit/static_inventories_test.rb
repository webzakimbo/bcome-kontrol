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

  end


  # test that static_inventory set as parent for server

end
