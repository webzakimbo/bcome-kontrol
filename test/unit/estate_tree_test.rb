
load "#{File.dirname(__FILE__)}/../base.rb"

class EstateTreeTest < ActiveSupport::TestCase
  include UnitTestHelper

  def given_a_dummy_estate_config
    {
      identifier: 'dummy',
      description: 'A dummy estate',
      type: 'collection',
      views: [
        {
          type: 'collection',
          identifier: 'whatever',
          description: 'and ever'
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
    Bcome::Node::Factory.send(:new).init_tree
  end

  def test_should_default_top_level_identifier_to_bcome_if_not_provided
    # Given
    config = given_a_dummy_estate_config
    config[:identifier] = nil

    mock_yaml_estate_load_return(config)

    # when
    estate = Bcome::Node::Factory.send(:new).init_tree

    # then
    estate.identifier == Bcome::Node::Base::DEFAULT_IDENTIFIER
  end

  def test_should_create_tree_views
    # Given
    config = given_a_dummy_estate_config
    mock_yaml_estate_load_return(config)

    estate = ::Bcome::Node::Collection.new(given_estate_setup_params)
    ::Bcome::Node::Collection.expects(:new).returns(estate)

    views = config[:views]

    factory = ::Bcome::Node::Factory.send(:new)
    factory.expects(:create_tree).with(estate, views)

    # When/then
    factory.init_tree
  end

  def test_should_validate_view_types
    # Given
    estate = given_a_dummy_estate
    views = [
      { type: 'i_dont_exist' }
    ]

    # When/then
    assert_raise ::Bcome::Exception::InvalidNetworkConfig do
      ::Bcome::Node::Factory.send(:new).create_tree(estate, views)
    end
  end

  def test_inventories_cant_have_subviews
    # Given
    estate = given_a_dummy_estate
    views = [
      { identifier: 'aninvalidview', description: 'invalid inventory as it has subviews', type: 'inventory', views: [{}, {}] }
    ]

    # When/then
    assert_raise ::Bcome::Exception::InventoriesCannotHaveSubViews do
      ::Bcome::Node::Factory.send(:new).create_tree(estate, views)
    end
  end

  def test_inventories_cannot_have_subviews_when_they_are_the_topmost_view
    # Given
    views = {
      type: 'inventory',
      identifier: 'topmostidentifier',
      description: 'a top level inventory with subviews',
      views: [
        { identifier: 'ishouldnotbehere' }
      ]
    }

    YAML.expects(:load_file).returns(views)

    # When/then
    assert_raise ::Bcome::Exception::InventoriesCannotHaveSubViews do
      ::Bcome::Node::Factory.send(:new).init_tree
    end
  end

  def test_inventories_must_have_valid_types_even_when_they_are_the_topmost_view
    # Given
    views = {
      type: 'aninvalidtype',
      identifier: 'topmostidentifier',
      description: 'a top level inventory with subviews'
    }

    YAML.expects(:load_file).returns(views)

    # when/then
    assert_raise ::Bcome::Exception::InvalidNetworkConfig do
      ::Bcome::Node::Factory.send(:new).init_tree
    end
  end

  def test_should_raise_appropriately_when_estate_config_file_cannot_be_found
    # Given
    YAML.expects(:load_file).raises(Errno::ENOENT)

    # when/then
    assert_raise ::Bcome::Exception::MissingNetworkConfig do
      ::Bcome::Node::Factory.send(:new).init_tree
    end
  end

  def test_should_raise_appropriately_when_yaml_in_invalid_in_estate_config
    # Given
    YAML.expects(:load_file).raises(ArgumentError)

    # When/then
    assert_raise ::Bcome::Exception::InvalidNetworkConfig do
      ::Bcome::Node::Factory.send(:new).init_tree
    end
  end

  def test_estate_is_assigned_its_subviews
    # Given
    estate = given_a_dummy_estate
    views = [
      { type: 'collection', identifier: 'collection1', description: 'I am collection 1' },
      { type: 'collection', identifier: 'collection2', description: 'I am collection 2' }
    ]

    # When
    ::Bcome::Node::Factory.send(:new).create_tree(estate, views)

    # Then
    assert !estate.resources.nil?
    assert !estate.resources.empty?
    assert estate.resources.size == 2

    # And also that
    estate.resources.each_with_index do |resource, index|
      assert resource.is_a?(::Bcome::Node::Collection)
      assert resource.parent == estate
      views[index].each do |key, value|
        assert resource.send(key) == value
      end
    end
  end

  def test_estate_can_create_subview_tree
    #  Given
    estate = given_a_dummy_estate

    views = given_basic_dummy_views
    # When
    ::Bcome::Node::Factory.send(:new).create_tree(estate, views)

    # Then
    assert estate.resources.size == 1 # 1 top-level estate resource

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
    assert level4.resources.empty?
  end

  def test_that_an_estate_may_have_a_default_identifier_and_description
    # Given
    identifier = 'myestate'
    description = 'all my stuff'

    # When
    estate = Bcome::Node::Collection.new(views: { identifier: identifier, description: description, type: 'inventory' })

    # Then
    assert estate.identifier == identifier
    assert estate.description == description
  end
end
