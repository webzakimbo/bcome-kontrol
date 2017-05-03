
load "#{File.dirname(__FILE__)}/../base.rb"

class EstateTreeTest < ActiveSupport::TestCase

  include UnitTestHelper

  def given_a_dummy_estate_config
    {
      :views => [
        {
          :type => "collection",
          :identifier => "whatever",
          :description => "and ever"
        }
      ] 
    }
  end

  def mock_yaml_estate_load_return(mocked_data)
    YAML.expects(:load_file).returns(mocked_data)
  end

  def test_we_load_an_estate_config_from_file
    # Given
    mock_yaml_estate_load_return(given_a_dummy_estate_config) 

    # When/then
    Bcome::Node::Factory.init_tree
  end

  def test_should_create_tree_views
    # Given
    config = given_a_dummy_estate_config
    mock_yaml_estate_load_return(config)

    estate = ::Bcome::Node::Collection.new(given_estate_setup_params)    
    ::Bcome::Node::Collection.expects(:new).returns(estate)

    view_data = config[:views]

    ::Bcome::Node::Factory.expects(:create_tree).with(estate, view_data)

    # When/then
    Bcome::Node::Factory.init_tree
  end

  def test_should_validate_view_types
    # Given
    estate = given_a_dummy_estate
    view_data = [
     { :type => "i_dont_exist" }
    ]

    # When/then
    assert_raise ::Bcome::Exception::InvalidEstateConfig do
      ::Bcome::Node::Factory.create_tree(estate,view_data)
    end
  end

  def test_inventories_cant_have_subviews
    # Given
    estate = given_a_dummy_estate
    view_data = [
     { :type => "inventory", :views => [ {}, {}] }
    ]

    # When/then
    assert_raise ::Bcome::Exception::InventoriesCannotHaveSubViews do
      ::Bcome::Node::Factory.create_tree(estate, view_data)
    end
  end

  def test_inventories_cannot_have_subviews_when_they_are_the_topmost_view
    # Given
    view_data = {
      :type => "inventory",
      :identifier => "topmostidentifier",
      :description => "a top level inventory with subviews",
      :views => [
        { :identifier => "ishouldnotbehere" }
      ]
    }

    YAML.expects(:load_file).returns(view_data)

    # When/then
    assert_raise ::Bcome::Exception::InventoriesCannotHaveSubViews do
      ::Bcome::Node::Factory.init_tree
    end
  end

  def test_inventories_must_have_valid_types_even_when_they_are_the_topmost_view
    # Given
    view_data = {
      :type => "aninvalidtype",
      :identifier => "topmostidentifier",
      :description => "a top level inventory with subviews"
    }
    
    YAML.expects(:load_file).returns(view_data)
 
    # when/then
    assert_raise ::Bcome::Exception::InvalidEstateConfig do
      ::Bcome::Node::Factory.init_tree
    end
  end

  def test_should_raise_appropriately_when_estate_config_file_cannot_be_found
    # Given
    YAML.expects(:load_file).throws(Errno::ENOENT) 

    # when/then
    assert_raise ::Bcome::Exception::MissingEstateConfig do
      ::Bcome::Node::Factory.init_tree
    end
  end

  def test_estate_is_assigned_its_subviews
    # Given
    estate = given_a_dummy_estate
    view_data = [
      { :type => "collection", :identifier => "collection1", :description => "I am collection 1"},
      { :type => "collection", :identifier => "collection2", :description => "I am collection 2"},
    ]

    # When
    ::Bcome::Node::Factory.create_tree(estate, view_data)

    # Then
    assert !estate.resources.nil?
    assert !estate.resources.empty?
    assert estate.resources.size == 2
  
    # And also that
    estate.resources.each_with_index do |resource, index|
      assert resource.is_a?(::Bcome::Node::Collection)
      assert resource.parent == estate
      view_data[index].each do |key, value|
        assert resource.send(key) == value
      end
    end
  end

  def test_estate_can_create_subview_tree
    #  Given
    estate = given_a_dummy_estate

    view_data = given_dummy_view_data

    # When
    ::Bcome::Node::Factory.create_tree(estate,view_data)

    # Then
    assert estate.resources.size == 1  # 1 top-level estate resource

    # But also that
    level1 = estate.resources.first
    assert level1.is_a?(::Bcome::Node::Collection)
    assert level1.parent == estate
    assert level1.resources.size == 1

    level2 = level1.resources.first
    assert level2.is_a?(::Bcome::Node::Collection)
    assert level2.parent == level1
    assert level2.resources.size == 1

    level3 = level2.resources.first 
    assert level3.is_a?(::Bcome::Node::Collection)  
    assert level3.parent == level2 
    assert level3.resources.size == 1

    level4 = level3.resources.first
    assert level4.is_a?(::Bcome::Node::Inventory)
    assert level4.parent == level3
    assert level4.resources.size == 0
  end

  def test_that_an_estate_may_have_a_default_identifier_and_description
    # Given
    identifier = "myestate"
    description = "all my stuff"

    # When
    estate = Bcome::Node::Collection.new({ :view_data => { :identifier => identifier, :description => description, :type => "inventory" }})

    # Then
    assert estate.identifier == identifier
    assert estate.description == description
  end


  # TODO -
  # test that can add any attributes we want onto the estate level
  # test that estate should be able to be an inventory?
  # estate can be an inventory or a collection, but inventory can't have views as per existing implementation
  # Inventory cannot have subviews

end
