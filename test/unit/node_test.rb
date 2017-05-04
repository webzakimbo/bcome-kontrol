load "#{File.dirname(__FILE__)}/../base.rb"

class NodeTest < ActiveSupport::TestCase
  include ::UnitTestHelper

  def test_should_initialize_node
    # Given
    description = given_a_random_string_of_length(5)
    identifier = given_a_random_string_of_length(5)
    type = given_a_random_string_of_length(5)

    params = {
      view_data: {
        description: description,
        identifier: identifier,
        type: type
      }
    }

    # when
    node = Bcome::Node::Collection.new(params)

    # Then
    assert node.is_a?(Bcome::Node::Base)
    assert node.is_a?(Bcome::Node::Collection)
    assert node.identifier == identifier
    assert node.description == description
    assert node.type == type
  end

  def test_ad_hoc_attributes_are_set
    # Given
    params = given_estate_setup_params

    #  Given a random attribute set to a random value
    random_attribute = given_a_random_string_of_length(10)
    random_value = given_a_random_string_of_length(10)
    params[:view_data][random_attribute] = random_value

    # When
    node = Bcome::Node::Collection.new(params)

    # Then
    assert node.send(random_attribute) == random_value
  end

  def test_description_is_required
    # Given
    config = {
      identifier: 'dummy',
      type: 'collection',
    }

    YAML.expects(:load_file).returns(config)

    # When/then
    assert_raise Bcome::Exception::MissingDescriptionOnView do
      Bcome::Node::Factory.init_tree
    end
  end

  def test_identifier_is_required_for_all_subnodes
    # Given
    config = {
      identifier: 'dummy',
      description: 'top level estate',
      type: 'collection',
      views: [
        {
         description: 'A sub view without an identifier',
         type: 'collection'
        }
      ]
    }

    YAML.expects(:load_file).returns(config)

    # When/then
    assert_raise Bcome::Exception::MissingIdentifierOnView do
      Bcome::Node::Factory.init_tree
    end
  end

  def test_type_is_required
    params = given_estate_setup_params
    params[:view_data].delete(:type)

    # When/then
    assert_raise Bcome::Exception::MissingTypeOnView do
      Bcome::Node::Collection.new(params)
    end
  end

  def test_init_estate
    # Given
    estate = Bcome::Node::Collection.new(given_estate_setup_params)
    ::Bcome::Node::Factory.expects(:init_tree).returns(estate)

    # When
    init_estate = ::Bcome::Node::Factory.init_tree

    # Then
    assert init_estate == estate
  end

  def test_should_be_able_to_load_a_resource_by_identifier
    # Given
    estate = given_a_dummy_estate
    view_data = given_dummy_view_data # one:two:three:four
    ::Bcome::Node::Factory.create_tree(estate, view_data)

    third_context = test_traverse_tree(estate, %w(one two three))
    fourth_context = test_traverse_tree(estate, %w(one two three four))

    # When/then
    assert fourth_context == third_context.resource_for_identifier('four')

    # And also that
    assert fourth_context.parent == third_context
  end

  def test_should_construct_network_with_network_data
    # Given
    collection = given_a_dummy_collection
    network_data = {}
    mocked_network_driver = mock("I'm a network driver")

    collection.expects(:network_data).returns(network_data)
    ::Bcome::Driver::Base.expects(:create_from_config).with(network_data).returns(mocked_network_driver)

    # when/then ... all our expectations are met
    network_driver_from_estate = collection.network_driver

    # and also that
    assert network_driver_from_estate == mocked_network_driver
  end

  def test_nodes_should_data_from_parents
    [
      [:network, :network_data],
      [:ec2_filters, :filters],
      [:ssh_settings, :ssh_data]
    ].each do |inheritable_attributes|
      view_key = inheritable_attributes[0]
      node_key = inheritable_attributes[1]
      nodes_should_inherit_config_data_from_parents(view_key, node_key)
      nodes_should_inherit_from_above_only_what_they_do_not_define_and_thus_override_themselves(view_key, node_key)
    end
  end

  def nodes_should_inherit_config_data_from_parents(view_key, node_key)
    # Given view data with tested configuration at the top level only
    col1_network_data = { foo: 'foo', bar: 'bar' }
    view_data = [
      { view_key => col1_network_data, :type => 'collection', :identifier => 'one', :description => 'desc1', :views => [
        { type: 'collection', identifier: 'two', description: 'desc1', views: [
          { type: 'collection', identifier: 'three', description: 'desc1' } # end col3
        ] } # end col2
      ] } # end col1
    ]

    # And given an estate with a generated tree structure
    estate = given_a_dummy_estate
    ::Bcome::Node::Factory.create_tree(estate, view_data)

    # And the resultant nodes
    nodes = all_nodes_in_tree(estate, %w(one two three))

    # When/then all nodes should have the same dataa
    nodes.each do |node|
      assert node.send(node_key) == col1_network_data
    end
  end

  def nodes_should_inherit_from_above_only_what_they_do_not_define_and_thus_override_themselves(view_key, node_key)
    # Given
    view_data = [
      { view_key => { foo: :bar, moo: :woo }, :type => 'collection', :identifier => 'one', :description => 'desc1', :views => [
        { type: 'collection', identifier: 'two', description: 'desc1', views: [
          { view_key => { foo: :some_other_value }, :type => 'collection', :identifier => 'three', :description => 'desc1' } # end col3
        ] } # end col2
      ] } # end col1
    ]

    # And given an estate with a generated tree structure
    estate = given_a_dummy_estate
    ::Bcome::Node::Factory.create_tree(estate, view_data)

    # And the resultant nodes
    nodes = all_nodes_in_tree(estate, %w(one two three))
    col1 = nodes[0]
    col2 = nodes[1]
    col3 = nodes[2]

    # When/then
    assert col1.send(node_key) == { foo: :bar, moo: :woo }
    assert col2.send(node_key) == col1.send(node_key)
    assert col3.send(node_key) == { foo: :some_other_value, moo: :woo }

    ### AND then also
    # Given
    view_data = [
      { view_key => { foo: :bar, moo: :woo }, :type => 'collection', :identifier => 'one', :description => 'desc1', :views => [
        { view_key => { do: :yes, moo: :something_else_again }, :type => 'collection', :identifier => 'two', :description => 'desc1', :views => [
          { view_key => { foo: :some_other_value, loo: 'something else entirely' }, :type => 'collection', :identifier => 'three', :description => 'desc1' } # end col3
        ] } # end col2
      ] } # end col1
    ]

    # And given an estate with a generated tree structure
    estate = given_a_dummy_estate
    ::Bcome::Node::Factory.create_tree(estate, view_data)

    # And the resultant nodes
    nodes = all_nodes_in_tree(estate, %w(one two three))
    col1 = nodes[0]
    col2 = nodes[1]
    col3 = nodes[2]

    # When/then
    assert col1.send(node_key) == { foo: :bar, moo: :woo }
    assert col2.send(node_key) == { do: :yes, foo: :bar, moo: :something_else_again }
    assert col3.send(node_key) == { do: :yes, foo: :some_other_value, moo: :something_else_again, loo: 'something else entirely' }
  end

  def test_identifiers_must_be_unique
    # Given
    config = {
      identifier: 'toplevel',
      description: 'the top level node',
      type: 'collection',
      views: [
        { identifier: 'one', description: 'node 1', type: 'collection' },
        { identifier: 'two', description: 'node 2', type: 'collection' },
        { identifier: 'one', description: 'node 1 again', type: 'collection' }
      ]
    }
    
    YAML.expects(:load_file).returns(config)

    # when/then
    assert_raise Bcome::Exception::NodeIdentifiersMustBeUnique do
      ::Bcome::Node::Factory.init_tree
    end
  end

  def test_that_identifiers_dont_have_spaces
    # Given
    config = {
      type: 'collection',
      description: 'invalid identifier name',
      identifier: ' foo'
    }

   YAML.expects(:load_file).returns(config)

   # when/then
   assert_raise Bcome::Exception::InvalidIdentifier do
     ::Bcome::Node::Factory.init_tree
   end
  end

  def test_that_identifiers_dont_have_spaces_two
    # Given
    config = {
      type: 'collection',
      description: 'invalid identifier name',
      identifier: ' foo '
    }

   YAML.expects(:load_file).returns(config)

   # when/then
   assert_raise Bcome::Exception::InvalidIdentifier do
     ::Bcome::Node::Factory.init_tree
   end
  end

  def test_that_identifiers_dont_have_spaces_three
    # Given
    config = {
      type: 'collection',
      description: 'invalid identifier name',
      identifier: 'foo '
    }

   YAML.expects(:load_file).returns(config)

   # when/then
   assert_raise Bcome::Exception::InvalidIdentifier do
     ::Bcome::Node::Factory.init_tree
   end
  end

  def test_that_identifiers_dont_have_spaces_four
    # Given
    config = {
      type: 'collection',
      description: 'invalid identifier name',
      identifier: 'f o o'
    }

   YAML.expects(:load_file).returns(config)

   # when/then
   assert_raise Bcome::Exception::InvalidIdentifier do
     ::Bcome::Node::Factory.init_tree
   end
  end


  def test_should_return_string_matching_method_missing_if_matches_a_node_identifier
    # Given
    method_symbol = given_a_random_string_of_length(4)

    config = {
      type: 'collection',
      description: 'a top level view',
      identifier: 'toplevel',
      views: [
        { type: 'collection', description: 'a collection', identifier: "#{method_symbol}"}
      ]
    } 

    YAML.expects(:load_file).returns(config)
    estate = ::Bcome::Node::Factory.init_tree

    # When
    method_as_a_string = estate.send(method_symbol)

    # Then
    assert method_as_a_string == method_symbol.to_s
  end

  def test_should_return_string_matching_constant_name_if_matches_a_node_identifier
    # Given
    constant_name = "FooBar"

    config = {
      type: 'collection',
      description: 'a top level view',
      identifier: 'toplevel',
      views: [
        { type: 'collection', description: 'a collection', identifier: "#{constant_name}" }
      ]

    }

    YAML.expects(:load_file).returns(config)
    estate = ::Bcome::Node::Factory.init_tree

    irb_context = mock("Irb context")
    workspace = mock("Mock irb workspace")
    workspace.expects(:main).returns(estate)
    irb_context.expects(:workspace).returns(workspace)
    IRB.expects(:CurrentContext).returns(irb_context)    

    # When
    constant_as_string = estate.class.const_get(constant_name)

    # Then
    assert constant_as_string == constant_name
  end

end
